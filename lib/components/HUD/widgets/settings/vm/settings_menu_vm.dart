import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/widgets/pause/page/pause_menu.dart';
import 'package:fruit_collector/components/HUD/widgets/settings/page/settings_menu.dart';
import 'package:fruit_collector/fruit_collector.dart';

class SettingsMenuViewModel extends ChangeNotifier {
  late double hudSize;
  late double controlSize;
  late double gameVolume;
  late double musicVolume;
  late bool isLeftHanded;
  late bool showControls;

  late FruitCollector _game;

  void init({required FruitCollector game}) {
    _game = game;
    hudSize = game.settings.hudSize;
    controlSize = game.settings.controlSize;
    gameVolume = game.settings.gameVolume;
    musicVolume = game.settings.musicVolume;
    isLeftHanded = game.settings.isLeftHanded;
    showControls = game.settings.showControls;
  }

  void updateHudSize(double value) {
    hudSize = value;
    notifyListeners();
  }

  void updateControlSize(double value) {
    controlSize = value;
    notifyListeners();
  }

  void updateGameVolume(double value) {
    gameVolume = value;
    notifyListeners();
  }

  void updateMusicVolume(double value) {
    musicVolume = value;
    notifyListeners();
  }

  void updateIsLeftHanded(bool value) {
    isLeftHanded = value;
    notifyListeners();
  }

  void updateShowControls(bool value) {
    showControls = value;
    notifyListeners();
  }

  void applySettings() {
    _game.settings.hudSize = hudSize;
    _game.settings.controlSize = controlSize;
    _game.settings.isLeftHanded = isLeftHanded;
    _game.settings.showControls = showControls;
    _game.settings.gameVolume = gameVolume;
    _game.settings.musicVolume = musicVolume;
    _game.reloadAllButtons();
    _game.settingsService!.updateSettings(_game.settings);
  }

  void backToPauseMenu() {
    _game.overlays.remove(SettingsMenu.id);
    _game.overlays.add(PauseMenu.id);
  }

  void confirmAndBackToPauseMenu() {
    applySettings();
    backToPauseMenu();
  }
}