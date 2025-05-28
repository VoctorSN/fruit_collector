import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import 'package:fruit_collector/components/bbdd/models/game_character.dart';

import '../../../../../fruit_collector.dart';
import '../../../../bbdd/models/character.dart';


class CharacterSelection extends StatefulWidget {
  static const String id = 'character_selection';

  final PixelAdventure game;

  const CharacterSelection(this.game, {super.key});

  @override
  State<CharacterSelection> createState() => _CharacterSelectionState(game: game);
}

class _CharacterSelectionState extends State<CharacterSelection> {
  final PixelAdventure game;

  _CharacterSelectionState({required this.game});

  late Character currentCharacter = game.character.copy();
  late GameCharacter currentGameCharacter = game.characters[selectedCharacterIndex]['gameCharacter'];
  late final numCharacters = game.characters.length;
  late int selectedCharacterIndex = game.characters.indexWhere((c) => (c['character'] as Character).name == game.character.name);
  late final int userStars = game.starsPerLevel.values.reduce((a, b) => a + b);

  void nextCharacter() {
    setState(() {

      selectedCharacterIndex = (selectedCharacterIndex + 1) % numCharacters;
      currentCharacter = game.characters[selectedCharacterIndex]['character'];
    });
  }

  void previousCharacter() {
    setState(() {
      print('Previous character selected: $selectedCharacterIndex');
      print('Number of characters: $numCharacters');
      selectedCharacterIndex = (selectedCharacterIndex - 1 + numCharacters) % numCharacters;
      currentCharacter = game.characters[selectedCharacterIndex]['character'];
      print('Current character: ${currentCharacter.name}');
    });
  }

  void selectCharacter() {
    if (currentCharacter.requiredStars > userStars) return;
    goBack();
    selectedCharacter();
  }

  void goBack() {
    game.soundManager.resumeAll();
    game.overlays.remove(CharacterSelection.id);
    game.resumeEngine();
  }

  void selectedCharacter() {
    if (game.gameData == null) return;
    game.character = currentCharacter;
    game.updateCharacter();
  }

  @override
  Widget build(BuildContext context) {
    const Color baseColor = Color(0xFF212030);
    const Color cardColor = Color(0xFF3A3750);
    const Color borderColor = Color(0xFF5A5672);
    const Color textColor = Color(0xFFE1E0F5);

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: cardColor,
      foregroundColor: textColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: borderColor, width: 2),
      ),
      elevation: 6,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double maxWidth = (constraints.maxWidth * 0.6).clamp(0.0, 400.0);
              final double maxHeight = (constraints.maxHeight * 0.8).clamp(0.0, 350.0);
              final double avatarSize = (maxWidth / 3).clamp(80.0, 180.0);

              return Stack(
                children: [
                  Container(
                    width: maxWidth,
                    height: maxHeight,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF212030).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF5A5672), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentCharacter.name,
                          style: TextStyleSingleton().style.copyWith(
                            fontSize: 28,
                            color: const Color(0xFFE1E0F5),
                            shadows: const [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)],
                          ),
                        ),
                        SizedBox(
                          width: avatarSize * 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: previousCharacter,
                                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                                iconSize: 36,
                              ),
                              Container(
                                width: avatarSize,
                                height: avatarSize,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: ColorFiltered(
                                        colorFilter:
                                            currentCharacter.requiredStars > userStars
                                                ? const ColorFilter.matrix(<double>[
                                                  0.2126,
                                                  0.7152,
                                                  0.0722,
                                                  0,
                                                  0,
                                                  0.2126,
                                                  0.7152,
                                                  0.0722,
                                                  0,
                                                  0,
                                                  0.2126,
                                                  0.7152,
                                                  0.0722,
                                                  0,
                                                  0,
                                                  0,
                                                  0,
                                                  0,
                                                  1,
                                                  0,
                                                ])
                                                : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                                        child: Image.asset(
                                          'assets/images/Main Characters/${currentCharacter.name}/Jump.png',
                                          fit: BoxFit.cover,
                                          width: avatarSize,
                                          height: avatarSize,
                                        ),
                                      ),
                                    ),
                                    if (currentCharacter.requiredStars > userStars)
                                      const Icon(Icons.lock, color: Colors.white, size: 48),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: nextCharacter,
                                icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                                iconSize: 36,
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Text(
                            currentCharacter.description,
                            textAlign: TextAlign.center,
                            style: TextStyleSingleton().style.copyWith(
                              fontSize: 14,
                              color: const Color(0xFFE1E0F5),
                              shadows: const [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        currentCharacter.requiredStars > userStars
                                            ? Colors.grey.shade700
                                            : const Color(0xFF3A3750),
                                    foregroundColor: const Color(0xFFE1E0F5),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      side: BorderSide(
                                        color:
                                            currentCharacter.requiredStars > userStars
                                                ? Colors.grey.shade700
                                                : const Color(0xFF5A5672),
                                        width: 2,
                                      ),
                                    ),
                                    elevation: 6,
                                  ),
                                  onPressed: selectCharacter,
                                  icon: const Icon(Icons.check_circle_outline, color: Color(0xFFE1E0F5)),
                                  label: Text(
                                    'SELECT',
                                    style: TextStyleSingleton().style.copyWith(
                                      fontSize: 14,
                                      color: const Color(0xFFE1E0F5),
                                    ),
                                  ),
                                ),
                              ),
                              if (currentCharacter.requiredStars > userStars)
                                Positioned(
                                  right: 0,
                                  child: Row(
                                    children: [
                                      Text(
                                        '$userStars / ${currentCharacter.requiredStars}',
                                        style: TextStyleSingleton().style.copyWith(
                                          fontSize: 14,
                                          color: const Color(0xFFE1E0F5),
                                          shadows: const [
                                            Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 1),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.star, color: Colors.yellow.shade700, size: 20),
                                      const SizedBox(width: 16), // Padding right edge
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: goBack),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}