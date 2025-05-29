import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../base_widget.dart';
import '../vm/character_selection_vm.dart';
import '../widget/character_card_flip.dart';

class CharacterSelection extends StatelessWidget {
  static const String id = 'character_selection';

  final PixelAdventure game;

  const CharacterSelection(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget<CharacterSelectionVM>(
      model: CharacterSelectionVM(
        game: game,
        vsync: TickerProviderStub(),
      ),
onModelReady: (vm) {
  vm.refreshFromGame();
},

      builder: (context, vm, _) {
        // Colors
        const Color baseColor = Color(0xFF212030);
        const Color cardColor = Color(0xFF3A3750);
        const Color borderColor = Color(0xFF5A5672);
        const Color textColor = Color(0xFFE1E0F5);

        // Button style
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
                builder: (context, constraints) {
                  final double maxWidth = (constraints.maxWidth * 0.6).clamp(0.0, 400.0);
                  final double maxHeight = (constraints.maxHeight * 0.8).clamp(0.0, 350.0);
                  final double avatarSize = (maxWidth).clamp(80.0, 180.0);

                  return Stack(
                    children: [
                      // Main card container
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
                                  Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1),
                                ],
                              ),
                            ),

                            // Character flip widget with navigation
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
                                  CharacterCardFlip(
                                    angle: vm.angle,
                                    isFrontVisible: vm.rotation.value < 0.5,
                                    isUnlocked: vm.currentGameCharacter.unlocked,
                                    character: vm.currentCharacter,
                                    size: avatarSize,
                                    onTap: vm.flipCard,
                                  ),
                                  IconButton(
                                    onPressed: vm.nextCharacter,
                                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                                    iconSize: 36,
                                  ),
                                ],
                              ),
                            ),

                            // Description (still shown in card back, here kept for spacing)
                            const SizedBox(height: 16),

                            // Select button and star count
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
                                        backgroundColor: !vm.currentGameCharacter.unlocked
                                            ? Colors.grey.shade700
                                            : cardColor,
                                        foregroundColor: textColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          side: BorderSide(
                                            color: !vm.currentGameCharacter.unlocked
                                                ? Colors.grey.shade700
                                                : borderColor,
                                            width: 2,
                                          ),
                                        ),
                                        elevation: 6,
                                      ),
                                      onPressed: vm.selectCharacter,
                                      icon: const Icon(Icons.check_circle_outline, color: textColor),
                                      label: Text(
                                        'SELECT',
                                        style: TextStyleSingleton().style.copyWith(
                                          fontSize: 14,
                                          color: textColor,
                                        ),
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
                          onPressed: vm.goBack,
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

class TickerProviderStub extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}