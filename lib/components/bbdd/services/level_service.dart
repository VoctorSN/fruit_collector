import '../models/game_level.dart';
import '../repositories/level_repository.dart';

class LevelService {
  static LevelService? _instance;
  late final LevelRepository _levelRepository;

  LevelService._internal();

  static Future<LevelService> getInstance() async {
    if (_instance == null) {
      final service = LevelService._internal();
      service._levelRepository = await LevelRepository.getInstance();
      _instance = service;
    }
    return _instance!;
  }

  Future<List<Map<String, dynamic>>> getLevelsForGame(int gameId) async {
    final levels = await _levelRepository.getAllLevels();
    final gameLevels = await _levelRepository.getGameLevelsForGame(gameId);

    return levels.map((level) {
      final gameLevel = gameLevels.firstWhere(
        (gl) => gl.levelId == level.id,
        orElse:
            () => GameLevel(
              id: 0,
              levelId: level.id,
              gameId: gameId,
              completed: false,
              unlocked: false,
              stars: 0,
              dateCompleted: DateTime.parse('1970-01-01 00:00:00'),
              lastTimeCompleted: DateTime.parse('1970-01-01 00:00:00'),
              time: null,
              deaths: 0,
            ),
      );

      return {'level': level, 'gameLevel': gameLevel};
    }).toList();
  }

  Future<void> completeLevel({
    required int gameId,
    required int levelId,
    required int stars,
    required int time,
    required int deaths,
  }) async {
    var gameLevel = await _levelRepository.getGameLevel(gameId, levelId);
    final now = DateTime.now();

    if (gameLevel == null) {
      // Create a new GameLevel if it doesn't exist
      gameLevel = GameLevel(
        id: 0,
        // Will be set by AUTOINCREMENT
        levelId: levelId,
        gameId: gameId,
        completed: true,
        unlocked: true,
        stars: stars,
        dateCompleted: now,
        lastTimeCompleted: now,
        time: time,
        deaths: deaths,
      );
      final newId = await _levelRepository.insertGameLevel(gameLevel);
      gameLevel = GameLevel(
        id: newId,
        levelId: levelId,
        gameId: gameId,
        completed: true,
        unlocked: true,
        stars: stars,
        dateCompleted: now,
        lastTimeCompleted: now,
        time: time,
        deaths: deaths,
      );
    } else {
      // Update existing GameLevel
      gameLevel = GameLevel(
        id: gameLevel.id,
        levelId: gameLevel.levelId,
        gameId: gameLevel.gameId,
        completed: true,
        unlocked: true,
        stars: stars,
        dateCompleted: gameLevel.completed ? gameLevel.dateCompleted : now,
        // Keep first completion date
        lastTimeCompleted: now,
        time: time,
        deaths: deaths,
      );
      await _levelRepository.updateGameLevel(gameLevel);
    }

    // Unlock the next level (if it exists)
    final allLevels = await _levelRepository.getAllLevels();
    final currentLevelIndex = allLevels.indexWhere((level) => level.id == levelId);
    if (currentLevelIndex >= 0 && currentLevelIndex < allLevels.length - 1) {
      final nextLevelId = allLevels[currentLevelIndex + 1].id;
      var nextGameLevel = await _levelRepository.getGameLevel(gameId, nextLevelId);

      if (nextGameLevel == null) {
        nextGameLevel = GameLevel(
          id: 0,
          levelId: nextLevelId,
          gameId: gameId,
          completed: false,
          unlocked: true,
          stars: 0,
          dateCompleted: DateTime.parse('1970-01-01 00:00:00'),
          lastTimeCompleted: DateTime.parse('1970-01-01 00:00:00'),
          time: null,
          deaths: 0,
        );
        await _levelRepository.insertGameLevel(nextGameLevel);
      } else if (!nextGameLevel.unlocked) {
        nextGameLevel = GameLevel(
          id: nextGameLevel.id,
          levelId: nextGameLevel.levelId,
          gameId: nextGameLevel.gameId,
          completed: nextGameLevel.completed,
          unlocked: true,
          stars: nextGameLevel.stars,
          dateCompleted: nextGameLevel.dateCompleted,
          lastTimeCompleted: nextGameLevel.lastTimeCompleted,
          time: nextGameLevel.time,
          deaths: nextGameLevel.deaths,
        );
        await _levelRepository.updateGameLevel(nextGameLevel);
      }
    }
  }

  Future<GameLevel?> getGameLevelByGameAndLevelName({required int gameId, required String levelName}) async {
    // First, get the Level by name
    final levels = await _levelRepository.getAllLevels();
    final level = levels.firstWhere(
      (level) => level.name == levelName,
      orElse: () => throw Exception('Level with name $levelName not found'),
    );

    // Then, get the GameLevel using gameId and levelId
    return await _levelRepository.getGameLevel(gameId, level.id);
  }
}
