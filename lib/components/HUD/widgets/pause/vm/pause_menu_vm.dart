import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/widgets/pause/page/pause_menu.dart';

import '../../../../../fruit_collector.dart';
import '../../../style/text_style_singleton.dart';
import '../../main_menu/page/main_menu.dart';
import '../../settings/page/settings_menu.dart';

/// ViewModel for PauseMenu. Handles all logic and state.
class PauseMenuVM extends ChangeNotifier {
  final FruitCollector game;

  late final TextStyle textStyle;

  PauseMenuVM({required this.game}) {
    textStyle = TextStyleSingleton().style;
  }

  /// Text constants for buttons and title
  String get pauseTitle => 'PAUSED';
  String get resumeLabel => 'RESUME';
  String get settingsLabel => 'SETTINGS';
  String get mainMenuLabel => 'MAIN MENU';

  /// Determines if the resume button should be enabled
  bool get canResume => true;

  /// Called once when the ViewModel is attached. Stops background music if active.
  void initialize() {
    if (game.settings.isMusicActive) {
      game.soundManager.stopBGM();
    }
  }

  /// Resume the game: remove overlay, resume engine, restart appropriate BGM, resume sounds.
  void resumeGame() {
    game.overlays.remove(PauseMenu.id);
    game.resumeEngine();

    if (game.gameData != null && game.gameData!.currentLevel == game.levels.length - 1) {
      game.soundManager.startBossBGM(game.settings);
    } else {
      game.soundManager.startDefaultBGM(game.settings);
    }

    if (game.settings.isMusicActive) {
      game.soundManager.resumeAll();
    }
  }

  /// Open settings overlay
  void openSettings() {
    game.overlays.remove(PauseMenu.id);
    game.overlays.add(SettingsMenu.id);
  }

  /// Navigate to main menu: remove controls, remove overlay, add main menu, pause engine, stop/pause sounds.
  void goToMainMenu() {
    game.removeControls();
    game.overlays.remove(PauseMenu.id);
    game.overlays.add(MainMenu.id);
    game.pauseEngine();
    game.soundManager.stopBGM();
    game.soundManager.pauseAll();
  }
}