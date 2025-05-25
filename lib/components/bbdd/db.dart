import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseManager {
  static DatabaseManager? _instance;
  late final Database _database;

  DatabaseManager._internal();

  static Future<DatabaseManager> getInstance() async {
    if (_instance == null) {
      final DatabaseManager manager = DatabaseManager._internal();

      ///await manager._resetDatabase(); // ⚠️ Solo para desarrollo
      await manager._initDatabase();
      _instance = manager;
    }
    return _instance!;
  }

  ///For rebase de Database
  ///await databaseFactory.deleteDatabase(dbPath);
  Future<void> resetDatabase() async {
    final String dbPath = join(await databaseFactory.getDatabasesPath(), 'fruit_collector.db');
    await databaseFactory.deleteDatabase(dbPath);
  }

  Future<void> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else {
      databaseFactory = databaseFactory; // móvil usa la versión normal
    }

    final String dbPath = join(await databaseFactory.getDatabasesPath(), 'fruit_collector.db');
    print('Database path: $dbPath');

    _database = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await initializeDB(db);
        },
      ),
    );
  }

  Future<void> initializeDB(Database db) async {
    await db.execute('''
    CREATE TABLE Users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE
    );
  ''');

    // GAMES
    await db.execute('''
        CREATE TABLE Games (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          created_at TEXT NOT NULL DEFAULT '1970-01-01 00:00:00',
          last_time_played TEXT NOT NULL DEFAULT '1970-01-01 00:00:00',
          space INTEGER NOT NULL UNIQUE,
          current_level INTEGER NOT NULL DEFAULT 0,
          total_deaths INTEGER NOT NULL DEFAULT 0,
          total_time INTEGER NOT NULL DEFAULT 0,
          current_character INTEGER NOT NULL DEFAULT 0
        );
      ''');

    // SETTINGS
    await db.execute('''
        CREATE TABLE Settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_id INTEGER NOT NULL,
          HUD_size REAL NOT NULL DEFAULT 50.0,
          control_size REAL NOT NULL DEFAULT 50.0,
          is_left_handed INTEGER NOT NULL DEFAULT 0,
          show_controls INTEGER NOT NULL DEFAULT 0,
          is_music_active INTEGER NOT NULL DEFAULT 1,
          is_sound_enabled INTEGER NOT NULL DEFAULT 1,
          game_volume REAL NOT NULL DEFAULT 0.5,
          music_volume REAL NOT NULL DEFAULT 0.5,
          FOREIGN KEY (game_id) REFERENCES Games(id) ON DELETE CASCADE
        );
      ''');

    // ACHIEVEMENTS
    await db.execute('''
        CREATE TABLE Achievements (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL UNIQUE,
          description TEXT NOT NULL,
          difficulty INTEGER NOT NULL
        );
      ''');

    // LEVELS
    await db.execute('''
        CREATE TABLE Levels (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          difficulty INTEGER NOT NULL
        );
      ''');

    // GAMELEVEL
    await db.execute('''
        CREATE TABLE GameLevel (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          level_id INTEGER NOT NULL,
          game_id INTEGER NOT NULL,
          completed INTEGER NOT NULL DEFAULT 0,
          unlocked INTEGER NOT NULL DEFAULT 0,
          stars INTEGER NOT NULL DEFAULT 0,
          date_completed TEXT NOT NULL DEFAULT '1970-01-01 00:00:00',
          last_time_completed TEXT NOT NULL DEFAULT '1970-01-01 00:00:00',
          time INTEGER,
          deaths INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (level_id) REFERENCES Levels(id),
          FOREIGN KEY (game_id) REFERENCES Games(id) ON DELETE CASCADE
        );
      ''');

    // GAMEACHIEVEMENT
    await db.execute('''
        CREATE TABLE GameAchievement (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_id INTEGER NOT NULL,
          achievement_id INTEGER NOT NULL,
          date_achieved TEXT NOT NULL DEFAULT '1970-01-01 00:00:00',
          achieved INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (game_id) REFERENCES Games(id) ON DELETE CASCADE,
          FOREIGN KEY (achievement_id) REFERENCES Achievements(id)
        );
      ''');

    // INSERT INTO Achievements
    await db.insert('Achievements', {
      'id': 1001,
      'title': 'It Begins',
      'description':
          'Complete your first level. Every journey starts with a single step, even if that step lands directly on a spike trap. Unlock this achievement by finishing level 1 for the very first time.',
      'difficulty': 10,
    });

    await db.insert('Achievements', {
      'id': 1002,
      'title': 'The Chosen One',
      'description':
          'Conquer every single level in the game. You’ve crossed valleys, jumped through jungles, and survived countless bugs. Complete all available levels to earn this ultimate badge of honor.',
      'difficulty': 3,
    });

    await db.insert('Achievements', {
      'id': 1003,
      'title': 'Level 4: Reloaded',
      'description':
          'Overcome the chaos of level 4. You’ve witnessed fire traps, vanishing platforms, and physics-defying fruit. Survive all the hazards of level 4 and make it to the exit to unlock this.',
      'difficulty': 2,
    });

    await db.insert('Achievements', {
      'id': 1004,
      'title': 'Gotta Go Fast!',
      'description':
          'Finish the entire game in under 300 seconds. Speed through every level with lightning reflexes, memorized routes, and zero hesitation. Only true speedrunners will claim this.',
      'difficulty': 8,
    });

    await db.insert('Achievements', {
      'id': 1005,
      'title': 'Untouchable',
      'description':
          'Complete the full game without dying a single time. From start to finish, no deaths, no second chances. This requires absolute precision and deep knowledge of every level.',
      'difficulty': 5,
    });

    await db.insert('Achievements', {
      'id': 1006,
      'title': 'Shiny Hunter',
      'description':
          'Find every hidden star in level 5. Some are visible, others are hidden behind fake walls or require risky jumps. Explore thoroughly and leave no tile unturned.',
      'difficulty': 3,
    });

    await db.insert('Achievements', {
      'id': 1007,
      'title': 'No Hit Run: Level 2',
      'description':
          'Complete level 2 without taking any damage or dying. Avoid every trap, enemy, and hazard flawlessly. Timing, positioning, and nerves of steel are required.',
      'difficulty': 6,
    });

    await db.insert('Achievements', {
      'id': 1008,
      'title': 'Flashpoint',
      'description':
          'Clear level 6 in less than 15 seconds. Use perfect movement and any shortcuts you can find to defy space and time. This one demands absolute mastery.',
      'difficulty': 5,
    });

    // INSERT INTO Levels
    final List<Map<String, Object>> levels = [
      {'name': 'tutorial-01', 'difficulty': 1},
      {'name': 'tutorial-02', 'difficulty': 1},
      {'name': 'tutorial-03', 'difficulty': 2},
      {'name': 'tutorial-04', 'difficulty': 2},
      {'name': 'tutorial-05', 'difficulty': 3},
      {'name': 'level-01', 'difficulty': 4},
      {'name': 'level-02', 'difficulty': 4},
      {'name': 'level-03', 'difficulty': 5},
      {'name': 'level-04', 'difficulty': 5},
      {'name': 'level-05', 'difficulty': 6},
      {'name': 'level-06', 'difficulty': 6},
      {'name': 'level-07', 'difficulty': 7},
      {'name': 'level-08', 'difficulty': 8},
      {'name': 'level-09', 'difficulty': 8},
      {'name': 'level-98', 'difficulty': 9},
      {'name': 'level-99', 'difficulty': 9},
      {'name': 'level-100', 'difficulty': 10},
    ];

    for (final level in levels) {
      await db.insert('Levels', level);
    }
  }

  Database get database => _database;
}