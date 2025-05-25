import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';

import '../../../pixel_adventure.dart';

class CharacterSelection extends StatefulWidget {
  static const String id = 'character_selection';

  final PixelAdventure game;

  const CharacterSelection(this.game, {super.key});

  @override
  State<CharacterSelection> createState() => _CharacterSelectionState(game: game);
}

class _CharacterSelectionState extends State<CharacterSelection> {
  final PixelAdventure game;

  late int selectedIndex = game.gameData?.currentCharacter ?? 0;

  final List<String> characterAssets = [
    'assets/images/Main Characters/1/Jump.png',
    'assets/images/Main Characters/2/Jump.png',
    'assets/images/Main Characters/3/Jump.png',
    'assets/images/Main Characters/Mask Dude/Jump.png',
    'assets/images/Main Characters/Ninja Frog/Jump.png',
    'assets/images/Main Characters/Pink Man/Jump.png',
    'assets/images/Main Characters/Virtual Guy/Jump.png',
  ];

  _CharacterSelectionState({required this.game});

  void nextCharacter() {
    setState(() {
      selectedIndex = (selectedIndex + 1) % characterAssets.length;
    });
  }

  void previousCharacter() {
    setState(() {
      selectedIndex = (selectedIndex - 1 + characterAssets.length) % characterAssets.length;
    });
  }

  void selectCharacter() {
    game.soundManager.resumeAll();
    game.overlays.remove(CharacterSelection.id);
    game.resumeEngine();
    selectedCharacterIndex(selectedIndex);
  }

  void selectedCharacterIndex(int index) {
    if (game.gameData == null) return;
    game.gameData!.currentCharacter = index;
    game.player.updateCharacter(game.characters[index]);
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

              return Container(
                width: maxWidth,
                height: maxHeight,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CHARACTER',
                      style: TextStyleSingleton().style.copyWith(
                        fontSize: 28,
                        color: textColor,
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
                            child: Padding(
                              padding: EdgeInsets.all(avatarSize * 0.08),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(characterAssets[selectedIndex], fit: BoxFit.contain),
                              ),
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
                    ElevatedButton.icon(
                      style: buttonStyle,
                      onPressed: selectCharacter,
                      icon: const Icon(Icons.check_circle_outline, color: textColor),
                      label: Text('SELECT', style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
