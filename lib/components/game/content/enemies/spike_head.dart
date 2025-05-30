import 'dart:async' as async;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/blocks/collision_block.dart';

import '../../../../fruit_collector.dart';
import '../../level/sound_manager.dart';
import '../../util/custom_hitbox.dart';
import '../levelBasics/player.dart';

enum State { idle, atackDown, atackTop, atacking }

class SpikeHead extends SpriteAnimationGroupComponent with HasGameReference<FruitCollector>, CollisionCallbacks {
  bool isReversed = false;

  SpikeHead({super.position, super.size, this.isReversed = false});

  // Size and animations
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _atackDownAnimation;
  late final SpriteAnimation _atackAnimation;
  late final SpriteAnimation _atackTopAnimation;
  double stepTime = 0.1;
  final textureSize = Vector2(54, 52);
  CustomHitbox hitbox = CustomHitbox(offsetX: 7, offsetY: 7, width: 35, height: 35);

  static const Duration inmobileDuration = Duration(milliseconds: 350);

  // Attack logic
  bool isAtacking = false;
  bool isComingBack = false;
  static const attackVelocity = 100.0;
  static const comeBackVelocity = 25.0;
  static const detectDistance = 50;
  late Player player;
  late Vector2 initialPosition;
  Vector2 velocity = Vector2(0, 0);
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  async.FutureOr<void> onLoad() {
    add(RectangleHitbox(position: Vector2(hitbox.offsetX, hitbox.offsetY), size: Vector2(hitbox.width, hitbox.height)));

    initialPosition = position.clone()..round();

    _loadAllStates();

    player = game.player;

    return super.onLoad();
  }

  void _loadAllStates() {
    _idleAnimation = _spriteAnimation('Blink', 12);
    _atackDownAnimation = _spriteAnimation('Bottom Hit', 4)..loop = false;
    _atackAnimation = _spriteAnimation('Attack', 4)..loop = false;
    _atackTopAnimation = _spriteAnimation('Top Hit', 4)..loop = false;
    animations = {
      State.idle: _idleAnimation,
      State.atackDown: _atackDownAnimation,
      State.atacking: _atackAnimation,
      State.atackTop: _atackTopAnimation,
    };
    current = State.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Spike Head/$state (54x52).png'),
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: textureSize),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) other.collidedWithEnemy();
    if (other is CollisionBlock && !other.isPlatform) comeBack();
    super.onCollisionStart(intersectionPoints, other);
  }

  void _updateMovement(double dt) {
    var actualPosition = position.clone()..round();
    if (isComingBack && actualPosition == initialPosition) {
      position = initialPosition;
      velocity = Vector2.zero();
      Future.delayed(inmobileDuration, () => isComingBack = false);
    }
    position.y += velocity.y * dt;
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!isAtacking && !isComingBack) {
        checkPlayerPosition();
      }
      _updateMovement(fixedDeltaTime);
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void checkPlayerPosition() {
    final rockheadVisionLeft = x + hitbox.offsetX - detectDistance;
    final rockheadVisionRight = x + width - hitbox.offsetX + detectDistance;

    final playerY = player.y + player.height / 2;
    final rockheadY = y + height / 2;

    // Get the middle point of the player considering its direction
    final playerMid = player.x + (player.scale.x == -1 ? -player.width / 2 : player.width / 2);

    // Check if the center of the player is within the Rockhead's vision
    final isAligned = playerMid >= rockheadVisionLeft && playerMid <= rockheadVisionRight;

    // Check if the player is above or below the Rockhead
    final isAbove = playerY < rockheadY;

    if (isAligned && !isAbove && !isReversed) {
      attack(1);
    } else if (isAligned && isAbove && isReversed) {
      attack(-1);
    }
  }

  void attack(int direction) {
    if (isComingBack) return;
    if (game.settings.isSoundEnabled) {
      SoundManager().startRockheadAttackingLoop(game.settings.gameVolume);
    }
    isAtacking = true;
    velocity.y = attackVelocity * direction;
    current = State.atacking;
  }

  void comeBack() async {
    if (game.settings.isSoundEnabled) {
      SoundManager().stopRockheadAttackingLoop();
      SoundManager().playSmash(game.settings.gameVolume);
    }
    Future.delayed(inmobileDuration, () => velocity.y = isReversed ? comeBackVelocity : -comeBackVelocity);
    current = isReversed ? State.atackTop : State.atackDown;
    velocity = Vector2.zero();
    isComingBack = true;
    isAtacking = false;
    await animationTicker?.completed;
    current = State.idle;
  }
}
