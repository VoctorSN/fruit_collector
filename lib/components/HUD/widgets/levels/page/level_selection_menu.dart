import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../../base_widget.dart';
import '../vm/level_selection_menu_vm.dart';
import '../widget/level_card.dart';

class LevelSelectionMenu extends StatelessWidget {
  static const String id = 'level_selection_menu';

  final int totalLevels;
  final void Function(int) onLevelSelected;
  final PixelAdventure game;

  const LevelSelectionMenu({super.key, required this.game, required this.totalLevels, required this.onLevelSelected});

  @override
  Widget build(BuildContext context) {
    return BaseWidget<LevelSelectionMenuVM>(
      model: LevelSelectionMenuVM(),
      builder: (context, model, _) {
        const Color baseColor = Color(0xFF212030);
        const Color cardColor = Color(0xFF3A3750);
        const Color borderColor = Color(0xFF5A5672);
        const Color textColor = Color(0xFFE1E0F5);
        const double cardSpacing = 12;
        const double minCardSize = 90;
        const double minCardsPerRow = 3;
        void onBack() {
          game.soundManager.resumeAll();
          game.overlays.remove(LevelSelectionMenu.id);
          game.resumeEngine();
        }

        final ScrollController scrollController = ScrollController();

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
                  final double maxWidth = (constraints.maxWidth * 0.8).clamp(0.0, 800.0);
                  final double maxHeight = (constraints.maxHeight * 0.8).clamp(0.0, 600.0);
                  final double availableWidth = maxWidth - 96;
                  final double calculatedCardsPerRow = (availableWidth / (minCardSize + cardSpacing)).floorToDouble();
                  final double cardsPerRow = calculatedCardsPerRow.clamp(minCardsPerRow, double.infinity);
                  final double cardSize = (availableWidth - (cardSpacing * (cardsPerRow - 1))) / cardsPerRow;

                  void scrollByRow({required bool forward, required double rowSize}) {
                    final double rowHeight = rowSize + cardSpacing;
                    final double currentOffset = scrollController.offset;
                    final int currentRow = (currentOffset / rowHeight).round();

                    final int targetRow = forward ? currentRow + 1 : (currentRow - 1).clamp(0, double.infinity).toInt();
                    final double targetOffset = targetRow * rowHeight;

                    scrollController.animateTo(
                      targetOffset,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  }

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
                      children: [
                        Text(
                          'Select Level',
                          style: TextStyleSingleton().style.copyWith(
                            fontSize: 28,
                            color: textColor,
                            shadows: const [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Wrap(
                                      spacing: cardSpacing,
                                      runSpacing: cardSpacing,
                                      alignment: WrapAlignment.center,
                                      children: List.generate(totalLevels, (index) {
                                        final int level = index;
                                        final bool isUnlocked = game.unlockedLevelIndices.contains(level);
                                        final bool isCompleted = game.completedLevelIndices.contains(level);

                                        return SizedBox(
                                          height: cardSize,
                                          width: cardSize,
                                          child: LevelCard(
                                            isCurrentLevel: (game.gameData?.currentLevel ?? -1) == index,
                                            levelNumber: level,
                                            onTap: isUnlocked ? () => onLevelSelected(level) : null,
                                            cardColor: cardColor,
                                            stars: game.starsPerLevel[index] ?? 0,
                                            textColor: textColor,
                                            isLocked: !isUnlocked,
                                            isCompleted: isCompleted,
                                            difficulty: game.levels[index]['level'].difficulty ?? 0,
                                            deaths: game.levels[index]['gameLevel'].deaths ?? 0,
                                            duration: game.levels[index]['gameLevel'].time ?? 0,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildScrollButton(
                                    icon: Icons.keyboard_arrow_up,
                                    onPressed: () => scrollByRow(forward: false, rowSize: cardSize),
                                    color: cardColor,
                                    iconColor: textColor,
                                    borderColor: borderColor,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildScrollButton(
                                    icon: Icons.keyboard_arrow_down,
                                    onPressed: () => scrollByRow(forward: true, rowSize: cardSize),
                                    color: cardColor,
                                    iconColor: textColor,
                                    borderColor: borderColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(FontAwesomeIcons.skull, size: 12, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  '${game.gameData?.totalDeaths ?? 0}',
                                  style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: buttonStyle,
                              onPressed: onBack,
                              icon: const Icon(Icons.arrow_back, color: textColor),
                              label: Text(
                                'BACK',
                                style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${game.gameData?.totalTime ?? 0}',
                                  style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.access_time, size: 18, color: textColor),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required Color iconColor,
    required Color borderColor,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 4,
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 28),
        onPressed: onPressed,
        splashRadius: 24,
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(),
      ),
    );
  }
}
