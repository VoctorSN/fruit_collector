import 'package:flutter/material.dart';
import 'package:fruit_collector/components/bbdd/models/character.dart';
import 'package:fruit_collector/components/bbdd/models/game_character.dart';

class CharacterSelectionVM extends ChangeNotifier {
  final List<Map<String, dynamic>> characters;
  final int userStars;
  final Character initialCharacter;

  late final int numCharacters;
  late int selectedCharacterIndex;
  late Character currentCharacter;

  CharacterSelectionVM({required this.characters, required this.userStars, required this.initialCharacter}) {
    _initialize();
  }

  /// Initialize the character selection state
  void _initialize() {
    numCharacters = characters.length;
    selectedCharacterIndex = characters.indexWhere((c) => (c['character'] as Character).name == initialCharacter.name);
    if (selectedCharacterIndex < 0) {
      selectedCharacterIndex = 0;
    }
    currentCharacter = characters[selectedCharacterIndex]['character'];
  }

  /// Navigate to the next character
  void nextCharacter() {
    selectedCharacterIndex = (selectedCharacterIndex + 1) % numCharacters;
    currentCharacter = characters[selectedCharacterIndex]['character'];
    notifyListeners();
  }

  /// Navigate to the previous character
  void previousCharacter() {
    selectedCharacterIndex = (selectedCharacterIndex - 1 + numCharacters) % numCharacters;
    currentCharacter = characters[selectedCharacterIndex]['character'];
    notifyListeners();
  }

  /// Whether the current character is locked based on star requirements
  bool get isCurrentCharacterLocked {
    print('Checking if character ${currentCharacter.name} is locked $currentGameCharacter');
    return !currentGameCharacter.unlocked;
  }

  /// Get current game character linked to selected character
  GameCharacter get currentGameCharacter {
    return characters[selectedCharacterIndex]['gameCharacter'];
  }
}