import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/enemies/player_collidable.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../content/blocks/collision_block.dart';
import '../../util/collisionable_with_hitbox.dart';
import '../levelBasics/player.dart';

enum RadishState { flying, idle, run, hit }

class Radish extends SpriteAnimationGroupComponent
    with CollisionCallbacks, HasGameReference<FruitCollector>, PlayerCollidable, CollisionableWithHitbox {
  // Constructor and attributes
  final double offNeg;
  final double offPos;
  final List<CollisionBlock> collisionBlocks;
  final Vector2 spawnPosition;

  Radish({
    super.position,
    super.size,
    this.offPos = 0,
    this.offNeg = 0,
    required this.collisionBlocks,
    required this.spawnPosition,
  });

  // Animations logic
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _flyingAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;
  static const stepTime = 0.05;
  static final textureSize = Vector2(30, 38);
  @override
  late RectangleHitbox hitbox = RectangleHitbox(position: Vector2.zero(), size: Vector2(30, 38));

  // Movement logic (on air)
  static const tileSize = 16;
  late final rangePos = spawnPosition.x - offPos * tileSize;
  late final rangeNeg = spawnPosition.x + 32 + offNeg * tileSize;
  double moveDirection = -1;
  static const flySpeed = 45;
  double sineTime = 0;
  bool isFlying = true;
  Vector2 velocity = Vector2.zero();

  // Movement logic (on ground)
  final double _gravity = 9.8;
  final double _maximunVelocity = 1000;
  final double _terminalVelocity = 300;
  final double groundSpeed = 80;

  // Death logic
  static const _bounceHeight = 260.0;
  @override
  late final Player player;
  bool gotStomped = false;

  // Delta time logic
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    player = game.player;
    add(hitbox);
    _loadAllAnimations();
    return super.onLoad();
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle 2', 9);
    _flyingAnimation = _spriteAnimation('Idle 1', 6);
    _runAnimation = _spriteAnimation('Run', 12);
    _hitAnimation = _spriteAnimation('Hit', 5)..loop = false;

    animations = {
      RadishState.idle: _idleAnimation,
      RadishState.run: _runAnimation,
      RadishState.hit: _hitAnimation,
      RadishState.flying: _flyingAnimation,
    };

    current = RadishState.flying;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Radish/$state (30x38).png'),
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: textureSize),
    );
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotStomped) {
        if (isFlying) {
          _fly(fixedDeltaTime);
        } else {
          _applyGravity(fixedDeltaTime);
          _movement(fixedDeltaTime);
          _checkVerticalCollisions();
          _checkHorizontalCollisions();
        }
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (super.checkCollision(block)) {
        if (velocity.y > 0) {
          final radishBottom = position.y + size.y;
          final blockTop = block.y;
          if (radishBottom > blockTop && radishBottom - blockTop < size.y * 0.5) {
            velocity.y = 0;
            position.y = blockTop - size.y;
            break;
          }
        }
      }
    }
  }

  Future<void> _fly(double dt) async {
    const slowdownMargin = 48.0;

    final distanceToLeft = (position.x - rangePos).clamp(0.5, slowdownMargin);
    final distanceToRight = (rangeNeg - position.x).clamp(0.5, slowdownMargin);

    final proximity = min(distanceToLeft, distanceToRight);
    final speedFactor = (proximity / slowdownMargin).clamp(0.5, 4.5);

    velocity.x = moveDirection * flySpeed * speedFactor;
    position.x += velocity.x * dt;

    sineTime += dt;
    const amplitude = 8.0;
    const frequency = 2.0;
    position.y = spawnPosition.y + amplitude * sin(sineTime * frequency);

    await Future.delayed(const Duration(milliseconds: 400));
    if (position.x < rangePos) {
      turnBack(1);
    } else if (position.x > rangeNeg) {
      turnBack(-1);
    }
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform && super.checkCollision(block)) {
        if (velocity.x > 0) {
          position.x = block.x;
          turnBack(-1);
        } else if (velocity.x < 0) {
          position.x = block.x + block.width;
          turnBack(1);
        }
        velocity.x = 0;
        break;
      }
    }
  }

  void _movement(double dt) {
    velocity.x = moveDirection * groundSpeed;
    position.x += velocity.x * dt;
    current = RadishState.run;
  }

  void turnBack(double direction) {
    moveDirection = direction;
    flipHorizontallyAroundCenter();
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_maximunVelocity, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  @override
  void collidedWithPlayer() async {
    if (player.y + player.hitbox.height < position.y + 2) {
      if (game.settings.isSoundEnabled) SoundManager().playBounce(game.settings.gameVolume);
      player.velocity.y = -_bounceHeight;
      if (!isFlying) {
        current = RadishState.hit;
        gotStomped = true;
        await animationTicker?.completed;
        removeFromParent();
      } else {
        current = RadishState.idle;
        isFlying = false;
      }
    } else {
      player.collidedWithEnemy();
    }
  }
}