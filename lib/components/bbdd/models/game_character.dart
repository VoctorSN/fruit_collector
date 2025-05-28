class GameCharacter {
  final int id;
  final int gameId;
  final int characterId;
  bool unlocked;
  bool equipped;
  DateTime dateUnlocked;

  GameCharacter({
    required this.id,
    required this.gameId,
    required this.characterId,
    required this.unlocked,
    required this.equipped,
    required this.dateUnlocked,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'game_id': gameId,
      'character_id': characterId,
      'unlocked': unlocked ? 1 : 0,
      'equipped': equipped ? 1 : 0,
      'date_unlocked': dateUnlocked.toIso8601String(),
    };
  }

  static GameCharacter fromMap(Map<String, Object?> map) {
    return GameCharacter(
      id: map['id'] as int,
      gameId: map['game_id'] as int,
      characterId: map['character_id'] as int,
      unlocked: (map['unlocked'] as int) == 1,
      equipped: (map['equipped'] as int) == 1,
      dateUnlocked: DateTime.parse(map['date_unlocked'] as String),
    );
  }

  @override
  String toString() {
    return 'GameCharacter{id: $id, gameId: $gameId, characterId: $characterId, unlocked: $unlocked, equipped: $equipped}';
  }
}