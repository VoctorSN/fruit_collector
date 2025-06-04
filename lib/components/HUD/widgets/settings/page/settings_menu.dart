import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/widgets/settings/widget/game_volume_controller_widget.dart';
import 'package:fruit_collector/components/HUD/widgets/settings/widget/music_controller_widget.dart';
import 'package:fruit_collector/components/HUD/widgets/settings/widget/resize_controls.dart';
import 'package:fruit_collector/components/HUD/widgets/settings/widget/resize_hud.dart';
import 'package:fruit_collector/fruit_collector.dart';
import '../../../style/text_style_singleton.dart';
import '../../base_widget.dart';
import '../vm/settings_menu_vm.dart';

class SettingsMenu extends StatelessWidget {
  static const String id = 'settings_menu';

  final FruitCollector game;

  const SettingsMenu({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget<SettingsMenuViewModel>(
      model: SettingsMenuViewModel(),
      onModelReady: (SettingsMenuViewModel model) => model.init(game: game),
      builder: (BuildContext context, SettingsMenuViewModel model, Widget? _) {
        // UI colors and style
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
                          // Title section
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Text(
                              'Settings',
                              style: TextStyleSingleton().style.copyWith(fontSize: 46, color: textColor),
                            ),
                          ),
                          // Control widgets section
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              direction: Axis.vertical,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              spacing: 18,
                              children: [
                                ToggleMusicVolumeWidget(
                                  game: game,
                                  updateMusicVolume: model.updateMusicVolume,
                                ),
                                ToggleGameVolumeWidget(
                                  game: game,
                                  updateGameVolume: model.updateGameVolume,
                                ),
                                ResizeHUD(
                                  game: game,
                                  updateSizeHUD: model.updateHudSize,
                                ),
                                ResizeControls(
                                  game: game,
                                  updateSizeControls: model.updateControlSize,
                                  updateIsLeftHanded: model.updateIsLeftHanded,
                                  updateShowControls: model.updateShowControls,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Buttons section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                style: buttonStyle,
                                onPressed: model.backToPauseMenu,
                                icon: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
                                label: Text(
                                  'Back',
                                  style: TextStyleSingleton().style.copyWith(fontSize: 20, color: textColor),
                                ),
                              ),
                              const SizedBox(width: 24),
                              ElevatedButton.icon(
                                style: buttonStyle,
                                onPressed: model.confirmAndBackToPauseMenu,
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
      },
    );
  }
}