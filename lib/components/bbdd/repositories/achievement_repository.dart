import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db.dart';
import '../models/achievement.dart';
import '../models/game_achievement.dart';

class AchievementRepository {
  static AchievementRepository? _instance;
  late final Database _db;

  AchievementRepository._internal();

  static Future<AchievementRepository> getInstance() async {
    if (_instance == null) {
      final repo = AchievementRepository._internal();
      final dbManager = await DatabaseManager.getInstance();
      repo._db = dbManager.database;
      _instance = repo;
    }
    return _instance!;
  }

  Future<Achievement?> getAchievement(int achievementId) async {
    final List<Map<String, Object?>> result = await _db.query(
      'Achievements',
      where: 'id = ?',
      whereArgs: [achievementId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Achievement.fromMap(result.first);
  }

  Future<List<Achievement>> getAllAchievements() async {
    final List<Map<String, Object?>> result = await _db.query('Achievements', orderBy: 'difficulty');

    return result.map((map) => Achievement.fromMap(map)).toList();
  }

  Future<GameAchievement?> getGameAchievement(int gameId, int achievementId) async {
    final List<Map<String, Object?>> result = await _db.query(
      'GameAchievement',
      where: 'game_id = ? AND achievement_id = ?',
      whereArgs: [gameId, achievementId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return GameAchievement.fromMap(result.first);
  }

  Future<void> resetGameAchievements(int gameId) async {
    await _db.update(
      'GameAchievement',
      {
        'achieved': 0,
        'date_achieved': '1970-01-01 00:00:00',
      },
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
  }

  Future<void> updateGameAchievement(GameAchievement gameAchievement) async {
    await _db.update(
      'GameAchievement',
      gameAchievement.toMap(),
      where: 'id = ?',
      whereArgs: [gameAchievement.id],
    );
  }

  Future<List<GameAchievement>> getGameAchievementsForGame(int gameId) async {
    final List<Map<String, Object?>> result = await _db.query(
      'GameAchievement',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );

    return result.map(GameAchievement.fromMap).toList();
  }

  Future<int> insertGameAchievement(int gameId, int achievementId) async {
    return await _db.insert(
      'GameAchievement',
      {
        'game_id': gameId,
        'achievement_id': achievementId,
        'date_achieved': '1970-01-01 00:00:00',
        'achieved': 0,
      },
    );
  }

  Future<Iterable<Object?>> getUnlockedAchievementsForGame(int id) {
    return _db.query(
      'GameAchievement',
      where: 'game_id = ? AND achieved = 1',
      whereArgs: [id],
    ).then((value) {
      return value.map((e) => e['achievement_id']);
    });
  }
}