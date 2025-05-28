import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../fruit_collector.dart';
import '../widgets/levels/page/level_selection_menu.dart';

class LevelSelection extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {
  final double buttonSize;

  LevelSelection({required this.buttonSize});

  bool isAvaliable = true;

  @override
  FutureOr<void> onLoad() {
    priority = 102;
    sprite = Sprite(game.images.fromCache('GUI/HUD/levelButton.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(10, 10);

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isAvaliable) {
      return;
    }
    game.soundManager.pauseAll();
    game.overlays.add(LevelSelectionMenu.id);
    game.pauseEngine();
    super.onTapDown(event);
  }
}