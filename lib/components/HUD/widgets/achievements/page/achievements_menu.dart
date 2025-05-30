import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';
import 'package:fruit_collector/components/bbdd/models/achievement.dart';
import 'package:fruit_collector/components/bbdd/models/game_achievement.dart';
import 'package:fruit_collector/fruit_collector.dart';

import 'achievement_details.dart';

class AchievementMenu extends StatefulWidget {
  final FruitCollector game;
  final List<Map<String, dynamic>> achievements;

  const AchievementMenu(this.game, this.achievements, {super.key});

  static const String id = 'achievement_menu';

  @override
  State<AchievementMenu> createState() => _AchievementMenuState();
}

class _AchievementMenuState extends State<AchievementMenu> {
  final ScrollController _scrollController = ScrollController();

  static const double _rowHeight = 70;
  static const double _rowSpacing = 6;

  void _scrollByRow({required bool forward}) {
    final double currentOffset = _scrollController.offset;
    final int currentRow = (currentOffset / (_rowHeight + _rowSpacing)).round();
    final int targetRow = forward ? currentRow + 1 : (currentRow - 1).clamp(0, widget.achievements.length - 1);
    final double targetOffset = targetRow * (_rowHeight + _rowSpacing);

    _scrollController.animateTo(targetOffset, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _onBack() {
    widget.game.soundManager.resumeAll();
    widget.game.overlays.remove(AchievementMenu.id);
    widget.game.resumeEngine();
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
              final double maxWidth = (constraints.maxWidth * 0.8).clamp(0.0, 800.0);
              final double maxHeight = (constraints.maxHeight * 0.8).clamp(0.0, 600.0);

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
                      'ACHIEVEMENTS',
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
                            child: ListView.separated(
                              controller: _scrollController,
                              itemCount: widget.achievements.length,
                              separatorBuilder: (_, __) => const SizedBox(height: _rowSpacing),
                              itemBuilder: (BuildContext context, int index) {
                                final Map<String, dynamic> achievementData = widget.achievements[index];
                                final Achievement achievement = achievementData['achievement'];
                                final GameAchievement gameAchievement = achievementData['gameAchievement'];

                                final String trophyPath = gameAchievement.achieved
                                    ? 'assets/images/GUI/HUD/trophy_gold.png'
                                    : 'assets/images/GUI/HUD/trophy_gray.png';

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      widget.game.currentAchievement = achievement;
                                      widget.game.currentGameAchievement = gameAchievement;
                                      widget.game.overlays.add(AchievementDetails.id);
                                    });
                                  },
                                  child: Container(
                                    height: _rowHeight,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      border: Border.all(color: borderColor, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(trophyPath, width: 24, height: 24, fit: BoxFit.contain),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            achievement.title,
                                            style: const TextStyle(fontSize: 13, color: textColor),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 1),
                                          child: Image.asset(
                                            'assets/images/difficulty/difficulty${achievement.difficulty.clamp(1, 10)}-Photoroom.png',
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildScrollButton(
                                icon: Icons.keyboard_arrow_up,
                                onPressed: () => _scrollByRow(forward: false),
                                color: cardColor,
                                iconColor: textColor,
                                borderColor: borderColor,
                              ),
                              const SizedBox(height: 12),
                              _buildScrollButton(
                                icon: Icons.keyboard_arrow_down,
                                onPressed: () => _scrollByRow(forward: true),
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
                              '${widget.game.gameData?.totalDeaths ?? 0}',
                              style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: buttonStyle,
                          onPressed: _onBack,
                          icon: const Icon(Icons.arrow_back, color: textColor),
                          label: Text(
                            'BACK',
                            style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${widget.game.gameData?.totalTime ?? 0}',
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
        icon: Icon(icon, color: iconColor, size: 24),
        onPressed: onPressed,
        splashRadius: 20,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}