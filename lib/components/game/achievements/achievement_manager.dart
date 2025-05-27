import 'package:fruit_collector/components/bbdd/models/game_achievement.dart';
import 'package:fruit_collector/components/bbdd/models/game_level.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../../HUD/widgets/achievements/page/achievement_toast.dart';
import '../../bbdd/models/achievement.dart';
import '../../bbdd/services/achievement_service.dart';

class AchievementManager {
  // Constructor and attributes
  PixelAdventure game;

  AchievementManager({required this.game});

  // Logic of unlocking achievements
  List<Map<String, dynamic>> allAchievements = [];

  late final Map<String, Function> achievementConditions = {
    'It Begins': (PixelAdventure game) => (game.levels[0]['gameLevel'] as GameLevel).completed,
    'The Chosen One':
        (PixelAdventure game) => (game.levels.every((level) => (level['gameLevel'] as GameLevel).completed)),
    'Level 4: Reloaded': (PixelAdventure game) => (game.levels[3]['gameLevel'] as GameLevel).completed,
    'Untouchable':
        (PixelAdventure game) =>
            (game.levels.every((level) => (level['gameLevel'] as GameLevel).completed) &&
                game.gameData!.totalDeaths == 0),
    'Gotta Go Fast!':
        (PixelAdventure game) =>
            (game.levels.every((level) => (level['gameLevel'] as GameLevel).completed) &&
                game.gameData!.totalTime <= 300),
    'Shiny Hunter': (PixelAdventure game) => (game.levels[4]['gameLevel'] as GameLevel).stars == 3,
    'No Hit Run: Level 2':
        (PixelAdventure game) =>
            (game.levels[1]['gameLevel'] as GameLevel).completed &&
            (game.levels[1]['gameLevel'] as GameLevel).deaths == 0,
    'Flashpoint':
        (PixelAdventure game) =>
            (game.levels[5]['gameLevel'] as GameLevel).time != null &&
            (game.levels[5]['gameLevel'] as GameLevel).time! <= 15,
    'Completionist':
        (PixelAdventure game) => game.achievements.every((a) => (a['gameAchievement'] as GameAchievement).achieved),
    'Star Collector':
        (PixelAdventure game) => game.levels.every((level) => (level['gameLevel'] as GameLevel).stars == 3),
    'Death Defier': (PixelAdventure game) => game.levels.any((level) => (level['gameLevel'] as GameLevel).deaths >= 20),
    'Flawless Victory':
        (PixelAdventure game) =>
            game.levels.every((level) => (level['gameLevel'] as GameLevel).stars == 3) &&
            game.gameData!.totalDeaths == 0,
  };

  // Logic to show achievements
  final List<Achievement> _pendingToasts = [];
  bool _isShowingToast = false;

  void evaluate() async {
    final achievementService = await AchievementService.getInstance();
    allAchievements.clear();
    if (game.gameData == null) return;
    final achievementData = await achievementService.getAchievementsForGame(game.gameData!.id);
    final unlockedAchievements = await achievementService.getUnlockedAchievementsForGame(game.gameData!.id);
    print('unlockedAchievements $unlockedAchievements');
    allAchievements.addAll(achievementData);
    print('stats ${game.levels}');

    for (final achievementData in allAchievements) {
      Achievement achievement = achievementData['achievement'];
      GameAchievement gameAchievement = achievementData['gameAchievement'];
      final alreadyUnlocked = unlockedAchievements.contains(gameAchievement.achievementId);

      if (!alreadyUnlocked) {
        final condition = achievementConditions[achievement.title];
        if (condition != null && condition(game)) {
          _showAchievementUnlocked(achievement);
          game.achievements.where((ga) => ga['gameAchievement'].id == gameAchievement.id).forEach((gameAchievement) {
            gameAchievement['gameAchievement'].achieved = true;
          });
          achievementService.unlockAchievement(game.gameData!.id, gameAchievement.achievementId);
        }
      }
    }
  }

  void _showAchievementUnlocked(Achievement achievement) {
    _pendingToasts.add(achievement);
    _tryShowNextToast();
  }

  void _tryShowNextToast() {
    if (_isShowingToast || _pendingToasts.isEmpty) return;

    _isShowingToast = true;
    final nextAchievement = _pendingToasts.removeAt(0);

    game.currentShowedAchievement = nextAchievement;
    game.overlays.add(AchievementToast.id);

    Future.delayed(const Duration(seconds: 3), () {
      game.overlays.remove(AchievementToast.id);
      game.currentShowedAchievement = null;
      _isShowingToast = false;
      _tryShowNextToast();
    });
  }
}