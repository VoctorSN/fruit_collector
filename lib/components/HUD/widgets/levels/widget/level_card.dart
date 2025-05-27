import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../style/text_style_singleton.dart';

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final VoidCallback? onTap;
  final Color cardColor;
  final Color textColor;
  final int difficulty;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrentLevel;
  final int stars;
  final int duration;
  final int deaths;

  const LevelCard({
    super.key,
    required this.levelNumber,
    required this.onTap,
    required this.cardColor,
    required this.textColor,
    required this.difficulty,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrentLevel,
    required this.stars,
    required this.duration,
    required this.deaths,
  });

  Color _calculateBorderColor() {
    final int clamped = difficulty.clamp(0, 10);
    final double t = clamped / 10.0;
    return Color.lerp(Colors.green, Colors.red, t)!;
  }

  Color _lighten(Color color, double amount) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final HSLColor lighter = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lighter.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final Color disabledColor = Colors.grey.withOpacity(0.4);
    final Color baseBorderColor = _calculateBorderColor();

    final List<BoxShadow> boxShadow =
        isCurrentLevel
            ? [BoxShadow(color: baseBorderColor.withOpacity(0.8), blurRadius: 4, spreadRadius: 1)]
            : [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 4, offset: const Offset(2, 4))];

    final String timeText = isCompleted ? '$duration' : '?';
    final String deathsText = isCompleted ? '$deaths' : '?';

    final Color backgroundColor = isLocked
        ? disabledColor
        : isCurrentLevel
        ? _lighten(cardColor, 0.075)
        : cardColor;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        width: 120,
        height: 120,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: baseBorderColor, width: isCurrentLevel ? 3 : 2),
          boxShadow: boxShadow,
        ),
        child: Stack(
          children: [
            if (!isLocked) ...[
              Positioned(
                top: 4,
                left: 6,
                child: Row(
                  children: [
                    Text(deathsText, style: TextStyleSingleton().style.copyWith(fontSize: 12, color: Colors.white)),
                    const SizedBox(width: 2),
                    const Icon(FontAwesomeIcons.skull, size: 12, color: Colors.white),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                right: 6,
                child: Row(
                  children: [
                    Text(timeText, style: TextStyleSingleton().style.copyWith(fontSize: 12, color: Colors.white)),
                    const SizedBox(width: 2),
                    const Icon(Icons.access_time, size: 12, color: Colors.white),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  '${levelNumber + 1}',
                  style: TextStyleSingleton().style.copyWith(
                    fontSize: 22,
                    color: textColor,
                    shadows: const [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)],
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return Icon(Icons.star, size: 14, color: index < stars ? Colors.amber : Colors.grey);
                  }),
                ),
              ),
              Positioned(
                bottom: 4,
                left: 4,
                child: Icon(
                  isCompleted ? Icons.emoji_events : Icons.emoji_events_outlined,
                  color: isCompleted ? _calculateBorderColor() : Colors.white70,
                  size: 16,
                ),
              ),
            ],
            if (isLocked) const Center(child: Icon(Icons.lock, size: 28, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}