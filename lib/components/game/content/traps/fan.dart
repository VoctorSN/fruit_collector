import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../blocks/collision_block.dart';
import '../levelBasics/player.dart';
import 'air_effect.dart';

enum FanState { off, on }

class Fan extends SpriteAnimationGroupComponent with HasGameReference<PixelAdventure>, CollisionCallbacks {
  // Constructor and attributes
  final bool directionRight;
  final double fanDistance;
  Function(CollisionBlock) addCollisionBlock;

  Fan({
    super.position,
    super.size,
    this.directionRight = false,
    required this.addCollisionBlock,
    this.fanDistance = 10,
  });

  // Hitbox and animation attributes
  static const stepTime = 0.05;
  static const tileSize = 16.0;
  static final textureSize = Vector2(9, 23);
  late CollisionBlock collisionBlock;
  late final SpriteAnimation _offAnimation;
  late final SpriteAnimation _onAnimation;

  // Interactions logic
  late final Player player = game.player;
  late final fanDirection = directionRight ? 1.0 : -1.0;
  late final Vector2 windVelocity = Vector2(directionRight ? 50 : -50, 0);

  @override
  FutureOr<void> onLoad() {
    createHitbox();
    _loadAllAnimations();
    collisionBlock = CollisionBlock(position: position, size: size);
    addCollisionBlock(collisionBlock);
    position.x += directionRight ? tileSize : 0;
    scale = directionRight ? Vector2(-1, 1) : Vector2(1, 1);
    return super.onLoad();
  }

  void createHitbox() {
    Vector2 hitboxSize = Vector2(fanDistance * tileSize, size.y);
    add(RectangleHitbox(position: Vector2(-hitboxSize.x, 0), size: hitboxSize));

    add(AirEffect(size: hitboxSize, position: Vector2(-hitboxSize.x, 0)));
  }

  void _loadAllAnimations() {
    _offAnimation = _spriteAnimation('Off', 1);
    _onAnimation = _spriteAnimation('On (36x23)', 4);

    animations = {FanState.off: _offAnimation, FanState.on: _onAnimation};

    current = FanState.on;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fan/$state.png'),
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: textureSize),
    );
  }

  void collidedWithPlayer() {
    player.windVelocity = windVelocity;
    // bool isAnyKeyPressed = player.isLeftKeyPressed || player.isRightKeyPressed;
    // bool isRightKeyPressed = player.isRightKeyPressed;
    // bool isLeftKeyPressed = player.isLeftKeyPressed;
    //
    // if (!isAnyKeyPressed) {
    //   // Player isnt moving
    //   player.moveSpeed = 100;
    //   player.horizontalMovement = fanDirection;
    // } else if ((isRightKeyPressed && fanDirection < 0) ||
    //     (isLeftKeyPressed && fanDirection > 0)) {
    //   // Player is moving against the wind
    //   player.moveSpeed = 50;
    //   // Apply the correct direction of the player
    //   player.horizontalMovement = fanDirection * -1;
    // } else {
    //   // Player is moving with the wind
    //   player.moveSpeed = 200;
    //   // Apply the correct direction of the player
    //   player.horizontalMovement = fanDirection;
    // }
    // // Clamp para que el jugador no exceda ±1 (input normalizado)
    // player.horizontalMovement = player.horizontalMovement.clamp(-1.0, 1.0);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    player.windVelocity = Vector2.zero();
    // if (other is Player) {
    //   if (other.isOnGround) player.horizontalMovement = 0;
    //   other.moveSpeed = 100;
    // }
    super.onCollisionEnd(other);
  }
}