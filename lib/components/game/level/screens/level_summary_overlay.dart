import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fruit_collector/fruit_collector.dart';

class LevelSummaryOverlay extends StatelessWidget {
  final VoidCallback onContinue;
  final PixelAdventure game;

  LevelSummaryOverlay({
    super.key,
    required this.onContinue,
    required this.game,
  });

  String get levelName => game.level.levelName;
  int get difficulty => game.levels[game.gameData!.currentLevel]['level'].difficulty;
  int get deaths => game.level.deathCount;
  int get stars => game.level.starsCollected;
  int get time => game.level.levelTime;

  final Map<int, String> difficultyMap = {
    1: 'Super Easy',
    2: 'Easy',
    3: 'Medium',
    4: 'Pretty Hard',
    5: 'Hard',
    6: 'Expert',
    7: 'Master',
    8: 'Legendary',
    9: 'Godlike',
    10: 'Impossible',
  };

  @override
  Widget build(BuildContext context) {

    // Define max and min size constraints for the overlay
    const double minWidth = 450.0;
    const double maxWidth = 500.0;
    const double minHeight = 350.0;
    const double maxHeight = 500.0;

    final TextStyle titleStyle = const TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontFamily: 'ArcadeClassic',
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    );

    final TextStyle valueStyle = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontFamily: 'ArcadeClassic',
      fontWeight: FontWeight.bold,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [
            Container(color: Colors.black.withOpacity(0.85)),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: minWidth,
                  maxWidth: maxWidth,
                  minHeight: minHeight,
                  maxHeight: maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            levelName.toUpperCase(),
                            style: titleStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _iconValue(
                                    icon: FontAwesomeIcons.fire,
                                    value: _difficultyText(difficulty),
                                    style: valueStyle,
                                  ),
                                  const SizedBox(height: 20),
                                  _starsRow(stars),
                                ],
                              ),
                              const SizedBox(width: 40),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _iconValue(
                                    icon: FontAwesomeIcons.clock,
                                    value: _formatTime(time),
                                    style: valueStyle,
                                  ),
                                  const SizedBox(height: 20),
                                  _iconValue(
                                    icon: FontAwesomeIcons.skull,
                                    value: '$deaths',
                                    style: valueStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: onContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'CONTINUE',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'ArcadeClassic',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _iconValue({
    required IconData icon,
    required String value,
    required TextStyle style,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FaIcon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 12),
        Text(value, style: style),
      ],
    );
  }

  Widget _starsRow(int count) {
    const int totalStars = 3;
    List<Widget> stars = [];

    for (int i = 0; i < totalStars; i++) {
      stars.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: FaIcon(
            FontAwesomeIcons.solidStar,
            color: i < count ? Colors.white : Colors.white24,
            size: 20,
          ),
        ),
      );
    }

    return Row(children: stars);
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final String paddedSeconds = remainingSeconds.toString().padLeft(2, '0');
    return '$minutes:$paddedSeconds';
  }

  String _difficultyText(int value) {
    return difficultyMap[value] ?? 'Unknown';
  }
}