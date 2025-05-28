import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/enemies/player_collidable.dart';
import 'package:fruit_collector/components/game/content/enemies/projectiles/pee_projectile.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../content/blocks/collision_block.dart';
import '../../util/collisionable_with_hitbox.dart';
import '../levelBasics/player.dart';

enum PeeShooterState { idle, attack, hit }

class PeeShooter extends SpriteAnimationGroupComponent
    with CollisionCallbacks, HasGameReference<PixelAdventure>, PlayerCollidable, CollisionableWithHitbox {
  // Constructor and attributes
  final double range;
  final int lookDirection;
  final List<CollisionBlock> collisionBlocks;
  Function(dynamic) addSpawnPoint;

  PeeShooter({
    super.position,
    super.size,
    this.range = 0,
    required this.collisionBlocks,
    required this.addSpawnPoint,
    required this.lookDirection,
  });

  // Movement logic and interactions with player
  static const stepTime = 0.1;
  static const tileSize = 16;
  static const _bounceHeight = 260.0;
  static final textureSize = Vector2(44, 42);
  double rangeNeg = 0;
  double rangePos = 0;
  bool gotStomped = false;
  @override
  late final Player player;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  bool isAtacking = false;
  bool isDuringCoolDown = false;
  static const attackCouldDown = 3000;
  final projectileSize = Vector2.all(16);
  final Vector2 projectileVelocity = Vector2(50, 0);

  @override
  RectangleHitbox hitbox = RectangleHitbox();

  // Animations logic
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _attackAnimation;
  late final SpriteAnimation _hitAnimation;

  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    player = game.player;
    if (lookDirection == 1) {
      flipHorizontallyAroundCenter();
    }
    add(hitbox);
    _loadAllAnimations();
    _calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotStomped) {
        if (!isDuringCoolDown && checkPlayerInRange()) {
          attack();
        }
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 11);
    _attackAnimation = _spriteAnimation('Attack', 8)..loop = false;
    _hitAnimation = _spriteAnimation('Hit', 5)..loop = false;

    animations = {
      PeeShooterState.idle: _idleAnimation,
      PeeShooterState.attack: _attackAnimation,
      PeeShooterState.hit: _hitAnimation,
    };

    current = PeeShooterState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Plant/$state (44x42).png'),
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: textureSize),
    );
  }

  void _calculateRange() {
    if (lookDirection == 1) {
      rangeNeg = position.x;
      rangePos = position.x + range * tileSize;
    } else {
      rangeNeg = position.x - range * tileSize;
      rangePos = position.x;
    }
  }

  Future<void> attack() async {
    isDuringCoolDown = true;
    current = PeeShooterState.attack;
    await animationTicker?.completed;
    animationTicker?.reset();
    shootProjectile();
    current = PeeShooterState.idle;
    Future.delayed(const Duration(milliseconds: attackCouldDown), () {
      isDuringCoolDown = false;
    });
  }

  void shootProjectile() {
    final Vector2 projectilePosition = position + Vector2(lookDirection == 1 ? -projectileSize.x : 0 , height / 3);
    final Vector2 projectileFixedVelocity = Vector2(projectileVelocity.x * lookDirection,0);

    final projectile = PeeProjectile(
      position: projectilePosition,
      velocity: projectileFixedVelocity,
      size: projectileSize,
      addSpawnPoint: addSpawnPoint,
    );
    addSpawnPoint(projectile);
  }

  bool checkPlayerInRange() {
    // Adjust player's X position for sprite flip
    final playerOffset = player.scale.x < 0 ? -player.width : 0;
    final playerX = player.position.x + playerOffset;

    // Check if player is within range
    return playerX >= rangeNeg &&
        playerX <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  @override
  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.settings.isSoundEnabled) SoundManager().playBounce(game.settings.gameVolume);
      gotStomped = true;
      current = PeeShooterState.hit;
      player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }
}