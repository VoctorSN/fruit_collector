import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/widgets/settings/game_volume_controller_widget.dart';
import 'package:fruit_collector/components/HUD/widgets/settings/music_controller_widget.dart';
import 'package:fruit_collector/components/HUD/widgets/settings/resize_controls.dart';
import 'package:fruit_collector/components/HUD/widgets/settings/resize_hud.dart';

import '../../../../fruit_collector.dart';
import '../../style/text_style_singleton.dart';
import '../pause/page/pause_menu.dart';

class SettingsMenu extends StatelessWidget {
  static const String id = 'settings_menu';

  final FruitCollector game;

  SettingsMenu(this.game, {super.key});

  late double sizeHUD = game.settings.hudSize;
  late double sizeControls = game.settings.controlSize;
  late double gameVolume = game.settings.gameVolume;
  late double musicVolume = game.settings.musicVolume;
  late bool isLeftHanded = game.settings.isLeftHanded;
  late bool showControls = game.settings.showControls;

  updateSizeHUD(double newValue) => sizeHUD = newValue;

  updateSizeControls(double newValue) => sizeControls = newValue;

  updateMusicVolume(double newValue) => musicVolume = newValue;

  updateGameVolume(double newValue) => gameVolume = newValue;

  updateIsLeftHanded(bool newValue) => isLeftHanded = newValue;

  updateShowControls(bool newValue) => showControls = newValue;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = const Color(0xFF212030);
    final Color buttonColor = const Color(0xFF3A3750);
    final Color borderColor = const Color(0xFF5A5672);
    final Color textColor = const Color(0xFFE1E0F5);

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: textColor,
      minimumSize: const Size(160, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor, width: 2),
      ),
      elevation: 6,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: borderColor, width: 2),
              ),
              color: baseColor.withAlpha(217),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 90),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Text(
                          'Settings',
                          style: TextStyleSingleton().style.copyWith(fontSize: 46, color: textColor),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          direction: Axis.vertical,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          spacing: 18,
                          children: [
                            ToggleMusicVolumeWidget(game: game, updateMusicVolume: updateMusicVolume),
                            ToggleGameVolumeWidget(game: game, updateGameVolume: updateGameVolume),
                            ResizeHUD(game: game, updateSizeHUD: updateSizeHUD),
                            ResizeControls(
                              game: game,
                              updateSizeControls: updateSizeControls,
                              updateIsLeftHanded: updateIsLeftHanded,
                              updateShowControls: updateShowControls,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: buttonStyle,
                            onPressed: () {
                              game.overlays.remove(SettingsMenu.id);
                              game.overlays.add(PauseMenu.id);
                            },
                            icon: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
                            label: Text(
                              'Back',
                              style: TextStyleSingleton().style.copyWith(fontSize: 20, color: textColor),
                            ),
                          ),
                          const SizedBox(width: 24),
                          ElevatedButton.icon(
                            style: buttonStyle,
                            onPressed: () async {
                              game.overlays.remove(SettingsMenu.id);
                              game.overlays.add(PauseMenu.id);
                              game.settings.hudSize = sizeHUD;
                              game.settings.controlSize = sizeControls;
                              game.settings.isLeftHanded = isLeftHanded;
                              game.settings.showControls = showControls;
                              game.reloadAllButtons();
                              game.settings.gameVolume = gameVolume;
                              game.settings.musicVolume = musicVolume;
                              game.settingsService!.updateSettings(game.settings);
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.white),
                            label: Text(
                              'Apply',
                              style: TextStyleSingleton().style.copyWith(fontSize: 20, color: textColor),
                            ),
                          ),
                        ],
                      ),
                    ],
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