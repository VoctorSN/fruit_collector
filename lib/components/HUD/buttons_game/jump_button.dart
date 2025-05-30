import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../fruit_collector.dart';

class JumpButton extends PositionComponent
    with HasGameReference<FruitCollector>, TapCallbacks {
  final double buttonSize;
  late SpriteComponent buttonSprite;

  JumpButton(this.buttonSize);

  @override
  FutureOr<void> onLoad() {
    priority = 101;

    _setSizeAndPosition(game.size);

    buttonSprite = SpriteComponent(
      sprite: Sprite(game.images.fromCache('GUI/HUD/jumpButton.png')),
      size: Vector2.all(buttonSize * 2),
      anchor: Anchor.bottomLeft,
      position: game.settings.isLeftHanded
          ? Vector2(32, size.y - 32)
          : Vector2(size.x - buttonSize * 2 - 32, size.y - 32),
    );

    add(buttonSprite);

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    _setSizeAndPosition(gameSize);

    buttonSprite.size = Vector2.all(game.settings.controlSize * 2);

    buttonSprite.position = game.settings.isLeftHanded
        ? Vector2(32, size.y - 32)
        : Vector2(size.x - buttonSprite.size.x - 32, size.y - 32);
  }

  void _setSizeAndPosition(Vector2 gameSize) {
    size = Vector2(gameSize.x / 2, gameSize.y / 2);
    position = game.settings.isLeftHanded
        ? Vector2(0, gameSize.y / 2) // inferior izquierdo
        : Vector2(gameSize.x / 2, gameSize.y / 2); // inferior derecho
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}