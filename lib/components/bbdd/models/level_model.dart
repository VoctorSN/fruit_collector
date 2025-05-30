class Level {
  final int id;
  final String name;
  final int difficulty;

  Level({required this.id, required this.name, required this.difficulty});

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'difficulty': difficulty};
  }

  static Level fromMap(Map<String, Object?> map) {
    return Level(id: map['id'] as int, name: map['name'] as String, difficulty: map['difficulty'] as int);
  }

  @override
  String toString() {
    return 'Level{id: $id, name: $name, difficulty: $difficulty}';
  }
}
