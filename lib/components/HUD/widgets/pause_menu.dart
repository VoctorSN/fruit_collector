import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/widgets/settings/settings_menu.dart';

import '../../../fruit_collector.dart';
import '../style/text_style_singleton.dart';
import 'main_menu/main_menu.dart';

class PauseMenu extends StatelessWidget {
  static String id = 'PauseMenu';
  final FruitCollector game;

  const PauseMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    if (game.settings.isMusicActive) {
      game.soundManager.stopBGM();
    }

    final Color baseColor = const Color(0xFF212030);
    final Color buttonColor = const Color(0xFF3A3750);
    final Color borderColor = const Color(0xFF5A5672);
    final Color textColor = const Color(0xFFE1E0F5);

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: textColor,
      minimumSize: const Size(220, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor, width: 2),
      ),
      elevation: 8,
    );

    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: baseColor.withAlpha((0.95 * 255).toInt()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PAUSED',
                style: TextStyleSingleton().style.copyWith(
                  fontSize: 32,
                  color: textColor,
                  shadows: [const Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)],
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                style: buttonStyle,
                onPressed: () {
                  game.overlays.remove(PauseMenu.id);
                  game.resumeEngine();
                  if(game.gameData!.currentLevel == game.levels.length-1) {
                    game.soundManager.startBossBGM(game.settings);
                  }else {
                    game.soundManager.startDefaultBGM(game.settings);
                  }

                  if (game.settings.isMusicActive) {
                    game.soundManager.resumeAll();
                  }
                },
                icon: Icon(Icons.play_arrow, color: textColor),
                label: Text('RESUME', style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor)),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                style: buttonStyle,
                onPressed: () {
                  game.overlays.remove(PauseMenu.id);
                  game.overlays.add(SettingsMenu.id);
                },
                icon: Icon(Icons.settings, color: textColor),
                label: Text('SETTINGS', style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor)),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                style: buttonStyle,
                onPressed: () {
                  game.removeControls();
                  game.overlays.remove(PauseMenu.id);
                  game.overlays.add(MainMenu.id);
                  game.pauseEngine();
                  game.soundManager.stopBGM();
                  game.soundManager.pauseAll();
                },
                icon: Icon(Icons.home, color: textColor),
                label: Text('MAIN MENU', style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}