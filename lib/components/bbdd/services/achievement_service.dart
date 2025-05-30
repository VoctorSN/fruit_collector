import '../models/game_achievement.dart';
import '../repositories/achievement_repository.dart';

class AchievementService {
  static AchievementService? _instance;
  late final AchievementRepository _achievementRepository;

  AchievementService._internal();

  static Future<AchievementService> getInstance() async {
    if (_instance == null) {
      final service = AchievementService._internal();
      service._achievementRepository =
          await AchievementRepository.getInstance();
      _instance = service;
    }
    return _instance!;
  }

  Future<void> unlockAchievement(int gameId, int achievementId) async {
    var gameAchievement = await _achievementRepository.getGameAchievement(
      gameId,
      achievementId,
    );

    if (gameAchievement == null) {

      throw Exception('GameAchievement not found');
    }
    // Update to mark as achieved
    final updatedGameAchievement = GameAchievement(
      id: gameAchievement.id,
      gameId: gameAchievement.gameId,
      achievementId: gameAchievement.achievementId,
      dateAchieved: DateTime.now(),
      achieved: true,
    );

    await _achievementRepository.updateGameAchievement(updatedGameAchievement);
  }

  Future<void> resetAchievementsForGame(int gameId) async {
    if (gameId <= 0) {
      throw Exception('Invalid game ID');
    }
    await _achievementRepository.resetGameAchievements(gameId);
  }

  Future<List<Map<String, dynamic>>> getAchievementsForGame(int gameId) async {
    final achievements = await _achievementRepository.getAllAchievements();
    final gameAchievements = await _achievementRepository
        .getGameAchievementsForGame(gameId);

    return achievements.map((achievement) {
      final gameAchievement = gameAchievements.firstWhere(
        (ga) => ga.achievementId == achievement.id,
        orElse:
            () => GameAchievement(
              id: 0,
              gameId: gameId,
              achievementId: achievement.id,
              dateAchieved: DateTime.parse('1970-01-01 00:00:00'),
              achieved: false,
            ),
      );

      return {'achievement': achievement, 'gameAchievement': gameAchievement};
    }).toList();
  }

  Future<Iterable<Object?>> getUnlockedAchievementsForGame(int id) {
    return _achievementRepository.getUnlockedAchievementsForGame(id);
  }
}