class GameLevel {
  final int id;
  final int levelId;
  final int gameId;
  bool completed;
  bool unlocked;
  int stars;
  DateTime dateCompleted;
  DateTime lastTimeCompleted;
  int? time;
  int deaths;

  GameLevel({
    required this.id,
    required this.levelId,
    required this.gameId,
    required this.completed,
    required this.unlocked,
    required this.stars,
    required this.dateCompleted,
    required this.lastTimeCompleted,
    this.time,
    required this.deaths,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'level_id': levelId,
      'game_id': gameId,
      'completed': completed ? 1 : 0,
      'unlocked': unlocked ? 1 : 0,
      'stars': stars,
      'date_completed': dateCompleted.toIso8601String(),
      'last_time_completed': lastTimeCompleted.toIso8601String(),
      'time': time,
      'deaths': deaths,
    };
  }

  static GameLevel fromMap(Map<String, Object?> map) {
    return GameLevel(
      id: map['id'] as int,
      levelId: map['level_id'] as int,
      gameId: map['game_id'] as int,
      completed: (map['completed'] as int) == 1,
      unlocked: (map['unlocked'] as int) == 1,
      stars: map['stars'] as int,
      dateCompleted: DateTime.parse(map['date_completed'] as String),
      lastTimeCompleted: DateTime.parse(map['last_time_completed'] as String),
      time: map['time'] as int?,
      deaths: map['deaths'] as int,
    );
  }

  @override
  String toString() {
    return 'GameLevel{id: $id, levelId: $levelId, gameId: $gameId, completed: $completed, stars: $stars, unlocked: $unlocked, deaths: $deaths, time: $time} \n';
  }
}
