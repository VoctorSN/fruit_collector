class Achievement {
  final int id;
  final String title;
  final String description;
  final int difficulty;

  Achievement({required this.id, required this.title, required this.description, required this.difficulty});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      // Note: gameAchievements are not stored in the Achievements table,
      // so they are not included in toMap for the database
    };
  }

  static Achievement fromMap(Map<String, Object?> map) {
    return Achievement(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      difficulty: map['difficulty'] as int,
    );
  }

  @override
  String toString() {
    return 'Achievement{id: $id, title: $title, difficulty: $difficulty';
  }
}
