class Character {
  final int id;
  final String name;
  final String description;
  final int requiredStars;

  Character({required this.id, required this.name, required this.description, required this.requiredStars});

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'description': description, 'required_stars': requiredStars};
  }

  Character copy() {
    return Character(id: id, name: name, description: description, requiredStars: requiredStars);
  }

  static Character fromMap(Map<String, Object?> map) {
    return Character(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      requiredStars: map['required_stars'] as int,
    );
  }

  @override
  String toString() {
    return 'Character{id: $id, name: $name, stars: $requiredStars}';
  }
}
