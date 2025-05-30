import 'package:fruit_collector/components/bbdd/models/game_achievement.dart';
import 'package:fruit_collector/components/bbdd/models/game_level.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../HUD/widgets/achievements/page/achievement_toast.dart';
import '../../bbdd/models/achievement.dart';
import '../../bbdd/services/achievement_service.dart';

class AchievementManager {
  // Constructor and attributes
  FruitCollector game;

  AchievementManager({required this.game});

  // Logic of unlocking achievements
  List<Map<String, dynamic>> allAchievements = [];

  late final Map<String, Function> achievementConditions = {
    'It Begins': (FruitCollector game) => (game.levels[0]['gameLevel'] as GameLevel).completed,
    'The Chosen One':
        (FruitCollector game) => (game.levels.every((level) => (level['gameLevel'] as GameLevel).completed)),
    'Level 4: Reloaded': (FruitCollector game) => (game.levels[3]['gameLevel'] as GameLevel).completed,
    'Untouchable':
        (FruitCollector game) =>
            (game.levels.every((level) => (level['gameLevel'] as GameLevel).completed) &&
                game.gameData!.totalDeaths == 0),
    'Gotta Go Fast!':
        (FruitCollector game) =>
            (game.levels.every((level) => (level['gameLevel'] as GameLevel).completed) &&
                game.gameData!.totalTime <= 300),
    'Shiny Hunter': (FruitCollector game) => (game.levels[4]['gameLevel'] as GameLevel).stars == 3,
    'No Hit Run: Level 2':
        (FruitCollector game) =>
            (game.levels[1]['gameLevel'] as GameLevel).completed &&
            (game.levels[1]['gameLevel'] as GameLevel).deaths == 0,
    'Flashpoint':
        (FruitCollector game) =>
            (game.levels[5]['gameLevel'] as GameLevel).time != null &&
            (game.levels[5]['gameLevel'] as GameLevel).time! <= 15,
    'Completionist':
        (FruitCollector game) => game.achievements.every((a) => (a['gameAchievement'] as GameAchievement).achieved),
    'Star Collector':
        (FruitCollector game) => game.levels.every((level) => (level['gameLevel'] as GameLevel).stars == 3),
    'Death Defier': (FruitCollector game) => game.level.deathCount >= 20,
    'Flawless Victory':
        (FruitCollector game) =>
            game.levels.every((level) => (level['gameLevel'] as GameLevel).stars == 3) &&
            game.gameData!.totalDeaths == 0,
  };

  Future<void> evaluate() async {
    print("Starting achievement evaluation");
    final achievementService = await AchievementService.getInstance();
    allAchievements.clear();
    if (game.gameData == null) return;
    final achievementData = await achievementService.getAchievementsForGame(game.gameData!.id);
    final unlockedAchievements = await achievementService.getUnlockedAchievementsForGame(game.gameData!.id);
    print('unlockedAchievements $unlockedAchievements');
    allAchievements.addAll(achievementData);
    print('stats ${game.gameData}');
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
    game.pendingToasts['achievements']!.add(achievement);
    tryShowNextToast();
  }

  void tryShowNextToast() {
  if (game.isShowingAchievementToast || game.pendingToasts['achievements']!.isEmpty) return;

  game.isShowingAchievementToast = true;
  final nextAchievement = game.pendingToasts['achievements']!.removeAt(0);

  game.currentShowedAchievement = nextAchievement;
  game.overlays.add(AchievementToast.id);

  Future.delayed(const Duration(seconds: 3), () {
    game.overlays.remove(AchievementToast.id);
    game.currentShowedAchievement = null;
    game.isShowingAchievementToast = false;

    // Try to show the next achievement toast
    tryShowNextToast();

    // If no more achievement toasts are showing, try to show the next character toast
    if (!game.isShowingAchievementToast && game.pendingToasts['achievements']!.isEmpty) {
      game.characterManager.tryShowNextToast();
    }
  });
}

}