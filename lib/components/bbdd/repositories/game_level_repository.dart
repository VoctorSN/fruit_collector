import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db.dart';

class GameLevelRepository {
  static GameLevelRepository? _instance;
  late final Database _db;

  GameLevelRepository._internal();

  num get defaultUnlockedLevels => 5;

  static Future<GameLevelRepository> getInstance() async {
    if (_instance == null) {
      final repo = GameLevelRepository._internal();
      final dbManager = await DatabaseManager.getInstance();
      repo._db = dbManager.database;
      _instance = repo;
    }
    return _instance!;
  }

  Future<void> insertLevelsForGame({required int gameId}) async {
    final List<Map<String, Object?>> levels = await _db.query('Levels');
    for (int i = 0; i < levels.length; i++) {
      final level = levels[i];
      await _db.insert('GameLevel', {
        'game_id': gameId,
        'level_id': level['id'],
        'completed': 0,
        'unlocked': i < defaultUnlockedLevels ? 1 : 0, // Unlock the first five levels
        'stars': 0,
        'date_completed': '1970-01-01 00:00:00',
        'last_time_completed': '1970-01-01 00:00:00',
        'time': null,
        'deaths': -1,
      });
    }
  }

  Future<void> deleteGameLevelByGameId({required int gameId}) async {
    final rowsAffected = await _db.delete('GameLevel', where: 'game_id = ?', whereArgs: [gameId]);
    if (rowsAffected == 0) {
      throw Exception('No gameLevels found for gameId $gameId');
    }
  }

  unlockAllLevelsForGame({required int gameId}) {
    return _db.update('GameLevel', {'unlocked': 1}, where: 'game_id = ?', whereArgs: [gameId]);
  }
}
