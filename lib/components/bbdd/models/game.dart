class Game {
  final int id;
  final DateTime createdAt;
  DateTime lastTimePlayed;
  final int space;
  int currentLevel;
  int totalDeaths;
  int totalTime;

  Game({
    required this.id,
    required this.createdAt,
    required this.lastTimePlayed,
    required this.space,
    required this.currentLevel,
    required this.totalDeaths,
    required this.totalTime,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'last_time_played': lastTimePlayed.toIso8601String(),
      'space': space,
      'current_level': currentLevel,
      'total_deaths': totalDeaths,
      'total_time': totalTime,
    };
  }

  static Game fromMap(Map<String, Object?> map) {
    return Game(
      id: map['id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastTimePlayed: DateTime.parse(map['last_time_played'] as String),
      space: map['space'] as int,
      currentLevel: map['current_level'] as int,
      totalDeaths: map['total_deaths'] as int,
      totalTime: map['total_time'] as int,
    );
  }

  @override
  String toString() {
    return 'Game{id: $id, createdAt: $createdAt, lastTimePlayed: $lastTimePlayed, space: $space, currentLevel: $currentLevel, totalDeaths: $totalDeaths, totalTime: $totalTime}';
  }
}