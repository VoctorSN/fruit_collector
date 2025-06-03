import 'dart:io' show Platform, exit;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../fruit_collector.dart';
import '../../../../bbdd/models/game.dart';
import '../../../../bbdd/services/game_service.dart';
import '../page/game_selector.dart';
import '../page/main_menu.dart';

/// ViewModel for MainMenu. Does not mix SingleTickerProviderStateMixin here;
/// receives an external TickerProvider to create the animation.
class MainMenuVM extends ChangeNotifier {
  final FruitCollector game;
  final TickerProvider vsync;

  late final AnimationController _logoController;
  late final Animation<double> logoAnimation;

  late GameService _service;
  late Game _lastGame;

  bool _isSoundOn = true;
  bool _isLoading = true;

  bool get isSoundOn => _isSoundOn;
  bool get isLoading => _isLoading;

  String get titleText => 'FRUIT COLLECTOR';
  String get continueLabel => 'CONTINUE';
  String get loadGameLabel => 'LOAD GAME';
  String get quitLabel => 'QUIT';

  MainMenuVM({required this.game, required this.vsync}) {
    // Initializes the AnimationController with the external vsync
    _logoController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    logoAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(_logoController);
  }

  /// Initializes the ViewModel: loads the last game and controls the music.
  Future<void> initialize(BuildContext context) async {
    await _loadLastGame();
    _applyInitialMusic();
  }

  /// Returns true if the device is considered “mobile” (depending on kIsWeb or Platform).
  bool isMobile(BuildContext context) {
    if (kIsWeb) {
      return MediaQuery.of(context).size.width < 600;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Loads the last game from the service.
  Future<void> _loadLastGame() async {
    _service = await GameService.getInstance();
    _lastGame = await _service.getLastPlayedOrCreate();
    game.isOnMenu = true;
    await game.chargeSlot(_lastGame.space);

    _isLoading = false;
    _isSoundOn = game.settings.isMusicActive;
    notifyListeners();
  }

  /// Plays or stops the menu background music based on preference.
  void _applyInitialMusic() {
    if (_isSoundOn) {
      game.soundManager.startMenuBGM(game.settings);
    } else {
      game.soundManager.stopBGM();
    }
  }

  /// Toggles the sound state and updates persistent preferences.
  void toggleVolume() {
    _isSoundOn = !_isSoundOn;
    if (_isSoundOn) {
      game.soundManager.startMenuBGM(game.settings);
    } else {
      game.soundManager.stopBGM();
    }
    game.settings.isMusicActive = _isSoundOn;
    game.settingsService!.updateSettings(game.settings);
    notifyListeners();
  }

  /// Action for the CONTINUE button.
  Future<void> onContinuePressed() async {
    if (_isLoading) return;

    game.isOnMenu = false;
    game.overlays.remove(MainMenu.id);
    await game.chargeSlot(_lastGame.space);
    game.resumeEngine();

    if (_isSoundOn) {
      game.soundManager.startDefaultBGM(game.settings);
    }
  }

  /// Action for the LOAD GAME button.
  void onLoadGamePressed() {
    game.overlays.remove(MainMenu.id);
    game.overlays.add(GameSelector.id);
  }

  /// Action for the QUIT button.
  void onQuitPressed() {
    game.soundManager.stopBGM();
    if (Platform.isWindows) {
      exit(0);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }
}