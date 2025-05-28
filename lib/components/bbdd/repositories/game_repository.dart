import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db.dart';
import '../models/game.dart';

class GameRepository {
  static GameRepository? _instance;
  late final Database _db;

  GameRepository._internal();

  static Future<GameRepository> getInstance() async {
    if (_instance == null) {
      final GameRepository repo = GameRepository._internal();
      final DatabaseManager dbManager = await DatabaseManager.getInstance();
      repo._db = dbManager.database;
      _instance = repo;
    }
    return _instance!;
  }

  Future<Game?> getGameBySpace({required int space}) async {
    if (space < 1 || space > 3) {
      return null;
    }

    final List<Map<String, Object?>> result = await _db.query(
      'Games',
      where: 'space = ?',
      whereArgs: [space],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Game.fromMap(result.first);
  }

  Future<void> updateGameBySpace({required Game game}) async {
    print('Updating game with space: ${game.space} and last_time_played: ${game.lastTimePlayed}');
    final int count = await _db.update(
      'Games',
      {
        'created_at': game.createdAt.toIso8601String(),
        'last_time_played': DateTime.now().toIso8601String(),
        'current_level': game.currentLevel,
        'total_deaths': game.totalDeaths,
        'total_time': game.totalTime,
      },
      where: 'space = ?',
      whereArgs: [game.space],
    );

    if (count == 0) {
      // throw Exception('No game found with space ${game.space}');
    }
  }

  Future<int> insertGame({required int space}) async {
    final int gameId = await _db.insert('Games', {
      'created_at': DateTime.now().toIso8601String(),
      'last_time_played': DateTime.now().toIso8601String(),
      'space': space,
      'current_level': 0,
      'total_deaths': 0,
      'total_time': 0,
    });
    return gameId;
  }

  Future<void> deleteGameBySpace({required int space}) async {
    final rowsAffected = await _db.delete(
      'Games',
      where: 'space = ?',
      whereArgs: [space],
    );
    if (rowsAffected == 0) {
      throw Exception('No game found for space $space');
    }
  }
}