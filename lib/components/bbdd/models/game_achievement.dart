class GameAchievement {
  final int id;
  final int gameId;
  final int achievementId;
  DateTime dateAchieved;
  bool achieved;

  GameAchievement({
    required this.id,
    required this.gameId,
    required this.achievementId,
    required this.dateAchieved,
    required this.achieved,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'game_id': gameId,
      'achievement_id': achievementId,
      'date_achieved': dateAchieved.toIso8601String(),
      'achieved': achieved ? 1 : 0,
    };
  }

  static GameAchievement fromMap(Map<String, Object?> map) {
    return GameAchievement(
      id: map['id'] as int,
      gameId: map['game_id'] as int,
      achievementId: map['achievement_id'] as int,
      dateAchieved: DateTime.parse(map['date_achieved'] as String),
      achieved: (map['achieved'] as int) == 1,
    );
  }

  @override
  String toString() {
    return 'GameAchievement{id: $id, gameId: $gameId, achievementId: $achievementId, achieved: $achieved}';
  }
}
