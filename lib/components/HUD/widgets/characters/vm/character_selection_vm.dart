import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/widgets/characters/page/character_selection.dart';
import 'package:fruit_collector/components/bbdd/models/character.dart';
import 'package:fruit_collector/components/bbdd/models/game_character.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../utils/base_vm.dart';

class CharacterSelectionVM extends BaseModel {
  late final AnimationController animationController;
  late final Animation<double> rotation;
  bool isFront = true;

  final FruitCollector game;

  late int selectedCharacterIndex;
  late int numCharacters;
  late final int userStars;

  CharacterSelectionVM({required this.game, required TickerProvider vsync}) {
    animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: vsync);

    rotation = Tween<double>(begin: 0, end: 1).animate(animationController)..addListener(_notifyListeners);

    _initializeData();
  }

  void _notifyListeners() {
    if (!disposed) notifyListeners();
  }
void refreshFromGame() {
    print(game.characters);
  selectedCharacterIndex = game.characters.indexWhere(
    (c) => (c['character'] as Character).name == game.character.name,
  );

  numCharacters = game.characters.length;
  isFront = true;

  if (!disposed) notifyListeners();
}

  void _initializeData() {
    selectedCharacterIndex = game.characters.indexWhere(
      (c) => (c['character'] as Character).name == game.character.name,
    );

    numCharacters = game.characters.length;
    userStars = game.starsPerLevel.values.reduce((a, b) => a + b);
  }

  Character get currentCharacter => game.characters[selectedCharacterIndex]['character'];

  GameCharacter get currentGameCharacter => game.characters[selectedCharacterIndex]['gameCharacter'];

  void nextCharacter() {
    selectedCharacterIndex = (selectedCharacterIndex + 1) % numCharacters;
    _notifyListeners();
  }

  void previousCharacter() {
    selectedCharacterIndex = (selectedCharacterIndex - 1 + numCharacters) % numCharacters;
    _notifyListeners();
  }

  void selectCharacter() {
    if (!currentGameCharacter.unlocked) return;
    game.character = currentCharacter;
    game.updateCharacter();
    game.resumeEngine();
    game.overlays.remove(CharacterSelection.id);
  }

  void goBack() {
    game.soundManager.resumeAll();
    game.overlays.remove('character_selection');
    game.resumeEngine();
  }

  void flipCard() {
    if (isFront) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
    isFront = !isFront;
  }

  double get angle => rotation.value * pi;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}