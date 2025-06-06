import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../fruit_collector.dart';
import '../../../../bbdd/models/achievement.dart';
import '../../../style/text_style_singleton.dart';
import 'achievement_details.dart';
import 'achievements_menu.dart';

class AchievementToast extends StatelessWidget {
  static const String id = 'achievement_toast';
  final Achievement achievement;
  final VoidCallback onDismiss;
  final FruitCollector game;

  const AchievementToast({super.key, required this.achievement, required this.onDismiss, required this.game});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFF1E1B2E).withAlpha(230);
    final Color borderColor = const Color(0xFFF9D342);
    final Color textColor = const Color(0xFFF2F2F2);
    final Color titleColor = const Color(0xFFFFD700);

    void onTap() async {
      game.currentAchievement = achievement;
      game.currentGameAchievement = await game.achievementService?.getGameAchievementByIds(
        gameId: game.gameData!.id,
        achievementId: achievement.id,
      );
      game.soundManager.pauseAll();
      game.pauseEngine();
      game.overlays.add(AchievementMenu.id);
      game.overlays.add(AchievementDetails.id);
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) => onDismiss(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: borderColor, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(102), offset: const Offset(2, 2), blurRadius: 3),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 26),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Achievement unlocked',
                                style: TextStyleSingleton().style.copyWith(
                                  fontSize: 12, // Smaller text
                                  color: titleColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                achievement.title,
                                style: TextStyleSingleton().style.copyWith(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onDismiss,
                            child: const Icon(Icons.close, size: 18, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}