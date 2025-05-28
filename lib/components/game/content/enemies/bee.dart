import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/enemies/player_collidable.dart';
import 'package:fruit_collector/components/game/content/enemies/projectiles/bee_projectile.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../content/blocks/collision_block.dart';
import '../../util/utils.dart';
import '../levelBasics/player.dart';

enum BeeState { idle, attack, hit }

class Bee extends SpriteAnimationGroupComponent
    with CollisionCallbacks, HasGameReference<PixelAdventure>, PlayerCollidable {
  
  // Constructor and attributes
  final double offNeg;
  final double offPos;
  final List<CollisionBlock> collisionBlocks;
  Function(dynamic) addSpawnPoint;
  Bee({
    super.position,
    super.size,
    this.offPos = 0,
    this.offNeg = 0,
    required this.collisionBlocks,
    required this.addSpawnPoint,
  });

  // Movement logic and interactions with player
  static const stepTime = 0.1;
  static const tileSize = 16;
  static const runSpeed = 60;
  static const _bounceHeight = 260.0;
  static final textureSize = Vector2(36, 34);
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = 1;
  bool gotStomped = false;
  @override
  late final Player player;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  bool isAtacking = false;
  bool isDuringCoolDown = false;
  static const attackCouldDown = 1000;
  final projectileSize = Vector2.all(16);
  final Vector2 projectileVelocity = Vector2(0, 200);

  // Animations logic
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _attackAnimation;
  late final SpriteAnimation _hitAnimation;

  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    player = game.player;
    add(
      RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26)),
    );
    _loadAllAnimations();
    _calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotStomped) {
        _movement(fixedDeltaTime);
        _checkHorizontalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 6);
    _attackAnimation = _spriteAnimation('Attack', 8)..loop = false;
    _hitAnimation = _spriteAnimation('Hit', 5)..loop = false;

    animations = {
      BeeState.idle: _idleAnimation,
      BeeState.attack: _attackAnimation,
      BeeState.hit: _hitAnimation,
    };

    current = BeeState.idle;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollisionBee(this, block)) {
          if (velocity.x > 0) {
            position.x = block.x - width;
          }
          if (velocity.x < 0) {
            position.x = block.x + block.width;
          }
          velocity.x = 0;
        }
      }
    }
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Bee/$state (36x34).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _movement(double dt) async {
    if (isAtacking) return;
    velocity.x = 0;

    double beeOffset = (scale.x > 0) ? 0 : -width;
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    if (playerInRange()) {
      if (playerBelow()) {
        if (isDuringCoolDown) return;
        await attack();
        return;
      }
      targetDirection =
          (player.x + playerOffset > position.x + beeOffset) ? 1 : -1;
      velocity.x = targetDirection * runSpeed;
    }
    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    position.x += velocity.x * dt;
  }

  Future<void> attack() async {
    isAtacking = true;
    current = BeeState.attack;
    await animationTicker?.completed;
    animationTicker?.reset();
    shootProjectile();
    current = BeeState.idle;
    isAtacking = false;
    isDuringCoolDown = true;
    Future.delayed(const Duration(milliseconds: attackCouldDown), () {
      isDuringCoolDown = false;
    });
  }

  void shootProjectile() {
    final Vector2 projectilePosition =
        position + (Vector2(width, height) - projectileSize) / 2;

    final projectile = BeeProjectile(
      position: projectilePosition,
      velocity: projectileVelocity,
      size: projectileSize,
      addSpawnPoint: addSpawnPoint,
    );
    addSpawnPoint(projectile);
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y;
  }

  bool playerBelow() {
    double playerRight = getPlayerXPosition(player) + player.hitbox.width;
    double playerLeft = getPlayerXPosition(player);
    double midBeeX = position.x + width / 2;

    // player.hitbox.offsetX in second condition
    return playerRight >= midBeeX &&
        playerLeft <= midBeeX &&
        player.y + player.height > position.y;
  }

  @override
  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.settings.isSoundEnabled) SoundManager().playBounce(game.settings.gameVolume);
      gotStomped = true;
      current = BeeState.hit;
      player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }
}