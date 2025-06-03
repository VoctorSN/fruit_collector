import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/widgets/pause/vm/pause_menu_vm.dart';

import '../../../../../fruit_collector.dart';
import '../../base_widget.dart';


class PauseMenu extends StatelessWidget {
  static const String id = 'PauseMenu';
  final FruitCollector game;

  const PauseMenu({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget<PauseMenuVM>(
      // Provide the ViewModel instance
      model: PauseMenuVM(game: game),
      onModelReady: (PauseMenuVM vm) {
        // Initialize ViewModel (stop background music if needed)
        vm.initialize();
      },
      builder: (BuildContext context, PauseMenuVM vm, Widget? child) {
        // Define colors and button style
        const Color baseColor = Color(0xFF212030);
        const Color buttonColor = Color(0xFF3A3750);
        const Color borderColor = Color(0xFF5A5672);
        const Color textColor = Color(0xFFE1E0F5);

        final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          minimumSize: const Size(220, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: borderColor, width: 2),
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
                  // Title text
                  Text(
                    vm.pauseTitle,
                    style: vm.textStyle.copyWith(
                      fontSize: 32,
                      color: textColor,
                      shadows: const [
                        Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 1)
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Resume button
                  ElevatedButton.icon(
                    style: buttonStyle,
                    onPressed: vm.canResume ? vm.resumeGame : null,
                    icon: const Icon(Icons.play_arrow, color: textColor),
                    label: Text(
                      vm.resumeLabel,
                      style: vm.textStyle.copyWith(fontSize: 14, color: textColor),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Settings button
                  ElevatedButton.icon(
                    style: buttonStyle,
                    onPressed: vm.openSettings,
                    icon: const Icon(Icons.settings, color: textColor),
                    label: Text(
                      vm.settingsLabel,
                      style: vm.textStyle.copyWith(fontSize: 14, color: textColor),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Main menu button
                  ElevatedButton.icon(
                    style: buttonStyle,
                    onPressed: vm.goToMainMenu,
                    icon: const Icon(Icons.home, color: textColor),
                    label: Text(
                      vm.mainMenuLabel,
                      style: vm.textStyle.copyWith(fontSize: 14, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}