import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../fruit_collector.dart';
import '../widgets/pause_menu.dart';

class OpenMenuButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {

  final double buttonSize;

  OpenMenuButton({required this.buttonSize});

  bool isAvaliable = true;

  @override
  FutureOr<void> onLoad() {
    priority = 102;
    sprite = Sprite(game.images.fromCache('GUI/HUD/menuButton.png'));
    size = Vector2.all(buttonSize);
    position = Vector2(game.size.x - buttonSize - 20, 10);
    anchor = Anchor.topRight;
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(game.size.x - 10, 10);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isAvaliable) {
      return;
    }
    game.soundManager.pauseAll();
    game.pauseEngine();
    game.overlays.add(PauseMenu.id);
    game.pauseEngine();

    super.onTapDown(event);
  }
}