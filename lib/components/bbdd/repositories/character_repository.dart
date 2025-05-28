import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db.dart';
import '../models/character.dart';
import '../models/game_character.dart';

class CharacterRepository {
  static CharacterRepository? _instance;
  late final Database _db;

  CharacterRepository._internal();

  static Future<CharacterRepository> getInstance() async {
    if (_instance == null) {
      final repo = CharacterRepository._internal();
      final dbManager = await DatabaseManager.getInstance();
      repo._db = dbManager.database;
      _instance = repo;
    }
    return _instance!;
  }

  Future<Character?> getCharacter(int characterId) async {
    final List<Map<String, Object?>> result = await _db.query(
      'Characters',
      where: 'id = ?',
      whereArgs: [characterId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Character.fromMap(result.first);
  }

  Future<List<Character>> getAllCharacters() async {
    final List<Map<String, Object?>> result = await _db.query(
      'Characters',
      orderBy: 'required_stars',
    );

    return result.map(Character.fromMap).toList();
  }

  Future<GameCharacter?> getGameCharacter(int gameId, int characterId) async {
    final List<Map<String, Object?>> result = await _db.query(
      'GameCharacter',
      where: 'game_id = ? AND character_id = ?',
      whereArgs: [gameId, characterId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return GameCharacter.fromMap(result.first);
  }

  Future<void> resetGameCharacters(int gameId) async {
    await _db.update(
      'GameCharacter',
      {
        'unlocked': 0,
        'equipped': 0,
        'date_unlocked': '1970-01-01 00:00:00',
      },
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
  }

  Future<void> updateGameCharacter(GameCharacter gameCharacter) async {
    await _db.update(
      'GameCharacter',
      gameCharacter.toMap(),
      where: 'id = ?',
      whereArgs: [gameCharacter.id],
    );
  }

  Future<List<GameCharacter>> getGameCharactersForGame(int gameId) async {
    final List<Map<String, Object?>> result = await _db.query(
      'GameCharacter',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );

    return result.map(GameCharacter.fromMap).toList();
  }

  Future<int> insertGameCharacter(int gameId, int characterId) async {
    return await _db.insert(
      'GameCharacter',
      {
        'game_id': gameId,
        'character_id': characterId,
        'unlocked': 0,
        'equipped': 0,
        'date_unlocked': '1970-01-01 00:00:00',
      },
    );
  }

  Future<Iterable<Object?>> getUnlockedCharactersForGame(int gameId) async {
    final List<Map<String, Object?>> result = await _db.query(
      'GameCharacter',
      where: 'game_id = ? AND unlocked = 1',
      whereArgs: [gameId],
    );

    return result.map((e) => e['character_id']);
  }
}