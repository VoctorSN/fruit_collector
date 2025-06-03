import 'package:flutter/material.dart';

import '../../../../../fruit_collector.dart';
import '../../../../bbdd/models/game.dart';
import '../../../../bbdd/services/game_service.dart';
import '../page/game_selector.dart';
import '../page/main_menu.dart';

/// ViewModel for GameSelector. Handles loading, selecting, and deleting save slots.
class GameSelectorVM extends ChangeNotifier {
  final FruitCollector game;

  Game? _slot1;
  Game? _slot2;
  Game? _slot3;
  GameService? _gameService;
  int? _slotToDelete;

  Game? get slot1 => _slot1;
  Game? get slot2 => _slot2;
  Game? get slot3 => _slot3;

  int? get slotToDelete => _slotToDelete;

  String get titleText => 'SELECT SAVE SLOT';
  String get backLabel => 'BACK';

  GameSelectorVM({required this.game});

  /// Load GameService instance if needed
  Future<void> _ensureGameService() async {
    _gameService ??= await GameService.getInstance();
  }

  /// Load all three save slots from the database
  Future<void> loadSlots() async {
    await _ensureGameService();
    _slot1 = await _gameService!.getGameBySpace(space: 1);
    _slot2 = await _gameService!.getGameBySpace(space: 2);
    _slot3 = await _gameService!.getGameBySpace(space: 3);
    notifyListeners();
  }

  /// Called when user taps on a slot button
  Future<void> selectSlot(int slotNumber) async {
    game.isOnMenu = false;
    await game.chargeSlot(slotNumber);
    game.overlays.remove(GameSelector.id);
    game.resumeEngine();
  }

  /// Mark a slot for deletion (show confirmation modal)
  void confirmDelete(int slotNumber) {
    _slotToDelete = slotNumber;
    notifyListeners();
  }

  /// Cancel deletion (hide confirmation modal)
  void cancelDelete() {
    _slotToDelete = null;
    notifyListeners();
  }

  /// Delete the confirmed slot and reload slots
  Future<void> deleteSlot(int slotNumber) async {
    if (_gameService != null) {
      await _gameService!.deleteGameBySpace(space: slotNumber);
      await loadSlots();
    }
    _slotToDelete = null;
    notifyListeners();
  }

  /// Navigate back to main menu without selecting or deleting
  void goBackToMainMenu() {
    game.overlays.remove(GameSelector.id);
    game.overlays.add(MainMenu.id);
  }
}