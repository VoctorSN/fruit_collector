import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../../fruit_collector.dart';
import '../../game/content/levelBasics/player.dart';

class CustomJoystick extends PositionComponent with HasGameReference<FruitCollector>, TapCallbacks {
  final double controlSize;
  double leftMargin;

  late JoystickComponent joystick;
  late Player player = game.player;

  static const List<JoystickDirection> movementDirections = [
    JoystickDirection.left,
    JoystickDirection.right,
    JoystickDirection.upLeft,
    JoystickDirection.upRight,
    JoystickDirection.downLeft,
    JoystickDirection.downRight,
    JoystickDirection.down,
  ];

  bool wasIdle = true;

  CustomJoystick({required this.controlSize, required this.leftMargin});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    size = game.size;
    position = Vector2.zero();
    priority = 100; // Ensure the joystick is drawn above other components

    _addJoystick();
  }

  void _addJoystick() {
    joystick = JoystickComponent(
      priority: 15,
      anchor: Anchor.center,
      knob: SpriteComponent(sprite: Sprite(game.images.fromCache('GUI/HUD/Knob.png')), size: Vector2.all(controlSize)),
      knobRadius: controlSize,
      background: SpriteComponent(
        sprite: Sprite(game.images.fromCache('GUI/HUD/Joystick.png')),
        size: Vector2.all(controlSize * 2),
      ),
      margin: EdgeInsets.only(left: leftMargin, bottom: 32),
    );

    game.add(joystick);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.settings.showControls && movementDirections.contains(joystick.direction)) {
      wasIdle = false;
      _updateJoystick();
    } else if (!wasIdle && joystick.direction == JoystickDirection.idle) {
      wasIdle = true;
      player.isDownPressed = false;
      player.horizontalMovement = 0;
      joystick.position = Vector2(leftMargin + controlSize, game.size.y - 32 - controlSize);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    leftMargin = !game.settings.isLeftHanded ? 32 : size.x - controlSize * 2 - 32;
    joystick.position = Vector2(leftMargin + controlSize, size.y - 32 - controlSize);
  }

  void _updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        player.isDownPressed = false;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        player.isDownPressed = false;
        break;
      case JoystickDirection.down:
        player.isDownPressed = true;
        break;
      default:
        player.horizontalMovement = 0;
        player.isDownPressed = false;
        joystick.position = Vector2(leftMargin + controlSize, game.size.y - 32 - controlSize);
        break;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final Vector2 tapPosition = event.canvasPosition;
    final double screenWidth = game.size.x;
    final double screenHeight = game.size.y;

    final bool isLeftSideTap = tapPosition.x < screenWidth / 2;
    final bool isBottomHalf = tapPosition.y > screenHeight / 2;

    if (!isBottomHalf) return;

    final bool shouldHandleTap =
        (!game.settings.isLeftHanded && isLeftSideTap) || (game.settings.isLeftHanded && !isLeftSideTap);

    if (shouldHandleTap) {
      joystick.position = tapPosition;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    joystick.position = Vector2(leftMargin + controlSize, game.size.y - 32 - controlSize);
    super.onTapUp(event);
  }
}
