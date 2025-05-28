import 'dart:async' as async;
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/enemies/player_collidable.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../content/blocks/collision_block.dart';
import '../../util/collisionable_with_hitbox.dart';
import '../levelBasics/player.dart';
import '../levelExtras/confetti.dart';

enum SnailState { idle, walk, hit, shellWallHit, shellIdle }

class Snail extends SpriteAnimationGroupComponent with CollisionCallbacks, HasGameReference<PixelAdventure>, PlayerCollidable, CollisionableWithHitbox {
  // Constructor and attributes
  final double offNeg;
  final double offPos;
  final List<CollisionBlock> collisionBlocks;
  final int doorId;

  Snail({super.position, super.size, this.offPos = 0, this.offNeg = 0, required this.collisionBlocks, required this.doorId});

  static const stepTime = 0.1;
  static const tileSize = 16;
  double runSpeed = 60;
  static const _bounceHeight = 260.0;
  static final textureSize = Vector2(38, 24);
  final Random random = Random();
  bool isOnGround = false;
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = 1;
  bool gotStomped = false;
  @override
  late final Player player;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  int hp = 5;
  final double _gravity = 9.8;
  final double _jumpForce = 320;
  final double _maximunVelocity = 1000;
  final double _terminalVelocity = 300;
  int timeToJump = 0;
  int timeToTransformShell = 0;
  int timeToTransformSnail = 0;
  final double _noFlipDifference = 5;

  async.Timer? transformSnailTimer;
  late async.Timer transformShellTimer;
  late async.Timer jumpTimer;

  @override
  RectangleHitbox hitbox = RectangleHitbox(position: Vector2.zero(), size: Vector2(48, 48));

  // Animations logic
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _walkAnimation;
  late final SpriteAnimation _hitAnimation;
  late final SpriteAnimation _shellWallHitAnimation;
  late final SpriteAnimation _shellIdleAnimation;

  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    game.soundManager.stopBGM();
    game.soundManager.startBossBGM(game.settings);

    player = game.player;
    add(hitbox);
    _loadAllAnimations();
    _calculateRange();
    _startJumpTimer();
    _startTransformShellTimer();
    return super.onLoad();
  }

  @override
  void onRemove() {
    jumpTimer.cancel();
    transformShellTimer.cancel();
    if (transformSnailTimer != null) {
      transformSnailTimer!.cancel();
    }
    super.onRemove();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotStomped) {
        _movement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 15);
    _walkAnimation = _spriteAnimation('Walk', 10);
    _hitAnimation = _spriteAnimation('Hit', 5)..loop = false;
    _shellWallHitAnimation = _spriteAnimation('Shell Wall Hit', 4)..loop = false;
    _shellIdleAnimation = _spriteAnimation('Shell Idle', 6);

    animations = {
      SnailState.idle: _idleAnimation,
      SnailState.walk: _walkAnimation,
      SnailState.hit: _hitAnimation,
      SnailState.shellIdle: _shellIdleAnimation,
      SnailState.shellWallHit: _shellWallHitAnimation,
    };

    current = SnailState.idle;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (super.checkCollision(block)) {
          if (velocity.y > 0) {
            isOnGround = true;
            velocity.y = 0;
            position.y = block.y - hitbox.height;

            break;
          }
        }
      } else {
        if (super.checkCollision(block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height;
            isOnGround = true;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_maximunVelocity, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (super.checkCollision(block)) {
          if (velocity.x > 0) {
            position.x = block.x - width - (scale.x.clamp(-1, 0) * width);
          }
          if (velocity.x < 0) {
            position.x = block.x + block.width - (scale.x.clamp(-1, 0) * width);
          }
          velocity.x = 0;
          if (current == SnailState.shellIdle) {
            current = SnailState.shellWallHit;
            targetDirection = -targetDirection;
            animationTicker?.completed.then((_) {
              current = SnailState.shellIdle;
            });
          }
        }
      }
    }
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Snail/$state (38x24).png'),
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: textureSize),
    );
  }

  void _startJumpTimer() {
    timeToJump = random.nextInt(5) + 3;
    jumpTimer = async.Timer.periodic(Duration(seconds: timeToJump), (_) {
      _jump();
      timeToJump = random.nextInt(5) + 3;
    });
  }

  void _startTransformShellTimer() {
    timeToTransformShell = random.nextInt(10) + 4;
    transformShellTimer = async.Timer.periodic(Duration(seconds: timeToTransformShell), (_) {
      _transformShell();
      transformShellTimer.cancel();
      _startTransformSnailTimer();
    });
  }

  void _startTransformSnailTimer() {
    timeToTransformSnail = random.nextInt(20) + 4;
    transformSnailTimer = async.Timer.periodic(Duration(seconds: timeToTransformSnail), (_) {
      _transformSnail();
      transformSnailTimer!.cancel();
      _startTransformShellTimer();
    });
  }

  void _transformSnail() {
    if (current == SnailState.walk) return;
    current = SnailState.walk;
    runSpeed = 60;
  }

  void _transformShell() {
    if (current == SnailState.shellIdle) return;
    current = SnailState.shellIdle;
    runSpeed = 120;
  }

  void _jump() {
    if (isSnail()) return;
    if (game.settings.isSoundEnabled) SoundManager().playJump(game.settings.gameVolume);

    velocity.y = -_jumpForce;
    isOnGround = false;
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _movement(double dt) async {
    velocity.x = 0;

    double snailOffset = (scale.x > 0) ? 0 : -width;
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    if (!isSnail()) {
      if(targetDirection == 0) targetDirection = 1;
      velocity.x = targetDirection * runSpeed;
    } else if (playerInRange()) {
      targetDirection = 0;
      /// is left
      if(!(player.x + playerOffset > position.x + snailOffset)){
        targetDirection = -1;
      } else
        /// is right
        if (player.x + playerOffset - _noFlipDifference > position.x + snailOffset){
          targetDirection = 1;
      }
      if ((moveDirection > 0 && scale.x > 0) || (moveDirection < 0 && scale.x < 0)) {
        flipHorizontallyAroundCenter();
      }
      velocity.x = targetDirection * runSpeed;
    }
    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    position.x += velocity.x * dt;
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos;
  }

  @override
  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y && isSnail()) {
      if (game.settings.isSoundEnabled) SoundManager().playBounce(game.settings.gameVolume);
      current = SnailState.hit;
      player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      hp--;
      if (hp <= 0) {
        gotStomped = true;
        spawnConfetti(position);
        game.level.openDoor(doorId);
        game.soundManager.startDefaultBGM(game.settings);
        removeFromParent();
      }
      _transformShell();
    } else {
      if (!gotStomped) player.collidedWithEnemy();
    }
  }

  bool isSnail() {
    return [SnailState.walk, SnailState.idle, SnailState.hit].contains(current);
  }

  Future<void> spawnConfetti(Vector2 atPosition) async {
    final confetti = ConfettiEmitterComponent(
      origin: atPosition,
      count: 40,
    );
    game.level.add(confetti);
  }
}