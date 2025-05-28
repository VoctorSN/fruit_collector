import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db.dart';

class GameCharacterRepository {
  static GameCharacterRepository? _instance;
  late final Database _db;

  GameCharacterRepository._internal();

  static Future<GameCharacterRepository> getInstance() async {
    if (_instance == null) {
      final repo = GameCharacterRepository._internal();
      final dbManager = await DatabaseManager.getInstance();
      repo._db = dbManager.database;
      _instance = repo;
    }
    return _instance!;
  }

  Future<void> insertCharactersForGame({required int gameId}) async {
    final List<Map<String, Object?>> characters = await _db.query(
    'Characters',
    orderBy: 'required_stars ASC',
  );

  for (int i = 0; i < characters.length; i++) { /// unloks all characters that dont require stars
    final character = characters[i];

    final bool unlock = (character['required_stars'] as int) == 0;

    await _db.insert('GameCharacter', {
      'game_id': gameId,
      'character_id': character['id'],
      'unlocked': unlock ? 1 : 0,
      'equipped': 0,
      'date_unlocked': unlock
          ? DateTime.now().toIso8601String()
          : '1970-01-01 00:00:00',
    });
  }
  }

  Future<void> deleteGameCharactersByGameId({required int gameId}) async {
    final int rowsAffected = await _db.delete(
      'GameCharacter',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );

    if (rowsAffected == 0) {
      throw Exception('No characters found for gameId $gameId');
    }
  }
}