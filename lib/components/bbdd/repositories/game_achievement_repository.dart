import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db.dart';

class GameAchievementRepository {
  static GameAchievementRepository? _instance;
  late final Database _db;

  GameAchievementRepository._internal();

  static Future<GameAchievementRepository> getInstance() async {
    if (_instance == null) {
      final repo = GameAchievementRepository._internal();
      final dbManager = await DatabaseManager.getInstance();
      repo._db = dbManager.database;
      _instance = repo;
    }
    return _instance!;
  }

  Future<void> insertAchievementsForGame({required int gameId}) async {
    final List<Map<String, Object?>> achievements = await _db.query('Achievements');
    for (final achievement in achievements) {
      await _db.insert('GameAchievement', {
        'game_id': gameId,
        'achievement_id': achievement['id'],
        'date_achieved': '1970-01-01 00:00:00',
        'achieved': 0,
      });
    }
  }

  deleteGameAchievementByGameId({required int gameId}) async {
    final rowsAffected = await _db.delete(
      'GameAchievement',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
    if (rowsAffected == 0) {
      throw Exception('No achievement found for gameId $gameId');
    }
  }

  unlockAllAchievementsForGame({required int gameId}) {
    return _db.update(
      'GameAchievement',
      {'achieved': 1},
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
  }
}