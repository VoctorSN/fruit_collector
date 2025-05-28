import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../util/utils.dart';
import 'collision_block.dart';

class FallingBlock extends CollisionBlock with HasGameReference<PixelAdventure> {
  // Constructor and atributes
  int fallingDuration;
  final Vector2 initialPosition;
  bool isSideSensible;

  FallingBlock({
    required Vector2 position,
    required this.fallingDuration,
    this.isSideSensible = false,
    super.size,
    super.isPlatform,
  }) : initialPosition = position.clone(),
       super(position: position);

  // Falling logic
  late SpriteAnimationComponent sprite = SpriteAnimationComponent();
  bool isFalling = false;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  Vector2 fallingVelocity = Vector2(0, 50);
  bool isOnGround = false;

  // Make player fall with platform logic
  bool hasCollided = false;
  bool isPlayerOnPlatform = false;
  late Player player = game.player;
  late List<CollisionBlock> collisionBlocks = player.collisionBlocks;

  get fallingAnimation {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Falling Platforms/Off.png'),
      SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: Vector2(32, 10)),
    );
  }

  get idleAnimation {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Falling Platforms/On (32x10).png'),
      SpriteAnimationData.sequenced(amount: 4, stepTime: 0.75, textureSize: Vector2(32, 10)),
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    priority = -1;
    sprite.animation = idleAnimation;
    add(sprite);
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      // Check if the player is on the platform then start falling
      if (!isFalling && _checkPlayerOnPlatform() && !isOnGround) {
        _startFalling();
      }

      // When it falls moves the player with the platform
      if (isFalling) {
        final delta = fallingVelocity * fixedDeltaTime;
        // Check if the block is colliding with another block below
        if (!_checkBlockCollisionBelow(delta)) {
          position += delta;
        } else {
          isOnGround = true;
          _stopFalling();
        }
        if (_checkPlayerOnPlatform()) {
          player.position.y = position.y - player.hitbox.height - player.hitbox.offsetY;
        }
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void _startFalling() {
    // Flag to prevent multiple calls
    if (!isOnGround) {
      if (isFalling) return;
      isFalling = true;
      sprite.animation = fallingAnimation;
    }
  }

  void _stopFalling() {
    // Flag to prevent multiple calls
    if (!isFalling) return;
    isFalling = false;
    sprite.animation = fallingAnimation;
    _comeBack();
  }

  void _comeBack() async {
    await Future.delayed(const Duration(seconds: 3));
    add(MoveToEffect(initialPosition, EffectController(duration: 1.0, curve: Curves.easeInOut)));
    isOnGround = false;
    isFalling = false;
    hasCollided = false;
    sprite.animation = idleAnimation;
  }

  // Check if the player is on the platform (exactly on top, not on the sides)
  bool _checkPlayerOnPlatform() {
    final realPlayerX = getPlayerXPosition(player);
    final bool isWithinX;
    if (isFalling || isSideSensible) {
      isWithinX = realPlayerX + player.hitbox.width > position.x && realPlayerX < position.x + size.x;
    } else {
      isWithinX = realPlayerX > position.x && realPlayerX < position.x + size.x - player.hitbox.width;
    }

    final playerBottom = player.position.y + player.hitbox.offsetY + player.hitbox.height;
    final isOnTop = (playerBottom - position.y).abs() < 1; // Margin of 1 px

    return isWithinX && isOnTop;
  }

  // Check if the block is colliding with another block below
  bool _checkBlockCollisionBelow(Vector2 delta) {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        final futureBottom = position.y + size.y + delta.y;
        final blockTop = block.position.y;

        final intersectsHorizontally =
            (position.x + size.x > block.position.x) && (position.x < block.position.x + block.size.x);

        final intersectsVertically = futureBottom >= blockTop && position.y + size.y <= blockTop;

        if (intersectsHorizontally && intersectsVertically) {
          return true;
        }
      }
    }
    return false;
  }
}