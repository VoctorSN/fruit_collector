import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db.dart';
import '../models/settings.dart';

class SettingsRepository {
  static SettingsRepository? _instance;
  late final Database _db;

  SettingsRepository._internal();

  static Future<SettingsRepository> getInstance() async {
    if (_instance == null) {
      final repo = SettingsRepository._internal();
      final dbManager = await DatabaseManager.getInstance();
      repo._db = dbManager.database;
      _instance = repo;
    }
    return _instance!;
  }

  Future<void> insertDefaultsForGame({required int gameId}) async {
    await _db.insert('Settings', {
      'game_id': gameId,
      'HUD_size': 50.0,
      'control_size': 50.0,
      'is_left_handed': 0,
      'show_controls': Platform.isAndroid || Platform.isIOS ? 1 : 0,
      'is_music_active': 1,
      'is_sound_enabled': 1,
      'game_volume': 0.5,
      'music_volume': 0.35,
    });
  }

  Future<void> updateSettings(Settings settings) async {
    settings.hudSize.clamp(0.25, 1.0);
    settings.controlSize.clamp(0.25, 1.0);
    await _db.update('Settings', settings.toMap(), where: 'id = ?', whereArgs: [settings.id]);
  }

  Future<Settings?> getSettings(int gameId) async {
    final List<Map<String, Object?>> result = await _db.query(
      'Settings',
      where: 'game_id = ?',
      whereArgs: [gameId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Settings.fromMap(result.first);
  }
}
