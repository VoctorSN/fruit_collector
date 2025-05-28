import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';

import '../../../../../fruit_collector.dart';
import '../../base_widget.dart';
import '../vm/character_selection_vm.dart';

class CharacterSelection extends StatelessWidget {
  static const String id = 'character_selection';

  final PixelAdventure game;

  const CharacterSelection(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget<CharacterSelectionVM>(
      model: CharacterSelectionVM(
        characters: game.characters,
        userStars: game.starsPerLevel.values.fold(0, (a, b) => a + b),
        initialCharacter: game.character.copy(),
      ),
      onModelReady: (vm) {},
      builder: (context, vm, _) {
        const Color baseColor = Color(0xFF212030);
        const Color cardColor = Color(0xFF3A3750);
        const Color borderColor = Color(0xFF5A5672);
        const Color textColor = Color(0xFFE1E0F5);

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
                      // Character selection modal container
                      Container(
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
                            // Character name
                            Text(
                              vm.currentCharacter.name,
                              style: TextStyleSingleton().style.copyWith(
                                fontSize: 28,
                                color: textColor,
                                shadows: const [
                                  Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)
                                ],
                              ),
                            ),
                            // Character avatar with arrows
                            SizedBox(
                              width: avatarSize * 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: vm.previousCharacter,
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
                                            colorFilter: vm.isCurrentCharacterLocked
                                                ? const ColorFilter.matrix(<double>[
                                                    0.2126, 0.7152, 0.0722, 0, 0,
                                                    0.2126, 0.7152, 0.0722, 0, 0,
                                                    0.2126, 0.7152, 0.0722, 0, 0,
                                                    0, 0, 0, 1, 0,
                                                  ])
                                                : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                                            child: Image.asset(
                                              'assets/images/Main Characters/${vm.currentCharacter.name}/Jump.png',
                                              fit: BoxFit.cover,
                                              width: avatarSize,
                                              height: avatarSize,
                                            ),
                                          ),
                                        ),
                                        if (vm.isCurrentCharacterLocked)
                                          const Icon(Icons.lock, color: Colors.white, size: 48),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: vm.nextCharacter,
                                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                                    iconSize: 36,
                                  ),
                                ],
                              ),
                            ),
                            // Character description
                            Center(
                              child: Text(
                                vm.currentCharacter.description,
                                textAlign: TextAlign.center,
                                style: TextStyleSingleton().style.copyWith(
                                  fontSize: 14,
                                  color: textColor,
                                  shadows: const [
                                    Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)
                                  ],
                                ),
                              ),
                            ),
                            // Select button with stars if locked
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
                                        backgroundColor: vm.isCurrentCharacterLocked
                                            ? Colors.grey.shade700
                                            : cardColor,
                                        foregroundColor: textColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          side: BorderSide(
                                            color: vm.isCurrentCharacterLocked
                                                ? Colors.grey.shade700
                                                : borderColor,
                                            width: 2,
                                          ),
                                        ),
                                        elevation: 6,
                                      ),
                                      onPressed: () {
                                        if (!vm.isCurrentCharacterLocked) {
                                          game.character = vm.currentCharacter;
                                          game.updateCharacter();
                                          game.soundManager.resumeAll();
                                          game.overlays.remove(CharacterSelection.id);
                                          game.resumeEngine();
                                        }
                                      },
                                      icon: const Icon(Icons.check_circle_outline, color: Color(0xFFE1E0F5)),
                                      label: Text(
                                        'SELECT',
                                        style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
                                      ),
                                    ),
                                  ),
                                    Positioned(
                                      right: 0,
                                      child: Row(
                                        children: [
                                          Text(
                                            '${vm.userStars} / ${vm.currentCharacter.requiredStars}',
                                            style: TextStyleSingleton().style.copyWith(
                                              fontSize: 14,
                                              color: textColor,
                                              shadows: const [
                                                Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 1),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.star, color: Colors.yellow.shade700, size: 20),
                                          const SizedBox(width: 16),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Close button
                      Positioned(
                        top: 6,
                        left: 6,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            game.soundManager.resumeAll();
                            game.overlays.remove(CharacterSelection.id);
                            game.resumeEngine();
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}