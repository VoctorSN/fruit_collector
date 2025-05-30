import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db.dart';
import '../models/game_level.dart';
import '../models/level_model.dart';

class LevelRepository {
  static LevelRepository? _instance;
  late final Database _db;

  LevelRepository._internal();

  static Future<LevelRepository> getInstance() async {
    if (_instance == null) {
      final repo = LevelRepository._internal();
      final dbManager = await DatabaseManager.getInstance();
      repo._db = dbManager.database;
      _instance = repo;
    }
    return _instance!;
  }

  Future<Level?> getLevel(int levelId) async {
    final List<Map<String, Object?>> result = await _db.query(
      'Levels',
      where: 'id = ?',
      whereArgs: [levelId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Level.fromMap(result.first);
  }

  Future<List<Level>> getAllLevels() async {
    final List<Map<String, Object?>> result = await _db.query('Levels');

    return result.map((map) => Level.fromMap(map)).toList();
  }

  Future<GameLevel?> getGameLevel(int gameId, int levelId) async {
    final List<Map<String, Object?>> result = await _db.query(
      'GameLevel',
      where: 'game_id = ? AND level_id = ?',
      whereArgs: [gameId, levelId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return GameLevel.fromMap(result.first);
  }

  Future<List<GameLevel>> getGameLevelsForGame(int gameId) async {
    final List<Map<String, Object?>> result = await _db.query(
      'GameLevel',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );

    return result.map(GameLevel.fromMap).toList();
  }

  Future<int> insertGameLevel(GameLevel gameLevel) async {
    return await _db.insert(
      'GameLevel',
      gameLevel.toMap(),
    );
  }

  Future<void> updateGameLevel(GameLevel gameLevel) async {
    await _db.update(
      'GameLevel',
      gameLevel.toMap(),
      where: 'id = ?',
      whereArgs: [gameLevel.id],
    );
  }
}