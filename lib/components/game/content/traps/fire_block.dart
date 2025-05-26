import 'dart:async' as async;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';
import 'package:fruit_collector/pixel_adventure.dart';

import '../../level/sound_manager.dart';
import '../../util/utils.dart';
import '../blocks/collision_block.dart';

enum FireBlockState { on, off }

class FireBlock extends PositionComponent with HasGameReference<PixelAdventure>, CollisionCallbacks {
  // Constructor and attributes
  final int startIn;
  final String fireDirection;
  final Function(CollisionBlock) addCollisionBlock;

  FireBlock({
    required this.startIn,
    required this.fireDirection,
    required this.addCollisionBlock,
    super.position,
    super.size,
  });

  // Animations and sounds logic
  late final SpriteAnimation onAnimation;
  late final SpriteAnimation offAnimation;
  late final SpriteAnimationGroupComponent<FireBlockState> fireSprite;
  static const stepTime = 0.05;
  static const double tileSize = 16.0;
  bool isOn = false;
  static final Map<int, int> _fireBlockCounters = {};

  // Player interaction logic
  late CollisionBlock collisionBlock;
  late RectangleHitbox attackHitbox;
  late final async.Timer timer;

  // Rotation logic
  static const double halfRotation = 3.14159;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _loadAnimations();

    // Extract the sprite to apply him the angle later
    fireSprite = SpriteAnimationGroupComponent<FireBlockState>(
      animations: {FireBlockState.on: onAnimation, FireBlockState.off: offAnimation},
      current: FireBlockState.off,
      size: size,
      anchor: Anchor.topLeft,
    );
    add(fireSprite);

    collisionBlock = CollisionBlock(
      position: Vector2(position.x, position.y + tileSize),
      size: Vector2(size.x, tileSize),
    );
    addCollisionBlock(collisionBlock);

    attackHitbox = RectangleHitbox(position: Vector2.zero(), size: Vector2(size.x, tileSize));
    add(attackHitbox);

    rotate();

    _fireBlockCounters[startIn] = (_fireBlockCounters[startIn] ?? 0) + 1;

    while (game.paused){
      await async.Future.delayed(const Duration(milliseconds: 100));
    }

    async.Future.delayed(Duration(seconds: startIn), _startPeriodicToggle);
  }

  @override
  void onRemove() {
    timer.cancel();
    super.onRemove();
  }

  void rotate() {
    Vector2 collisionPosition = position;
    Vector2 hitboxPosition = Vector2.zero();
    Vector2 spritePosition = Vector2.zero();
    double spriteAngle = 0;

    switch (fireDirection) {
      case 'Up':
        collisionPosition = Vector2(position.x, position.y + tileSize);
        break;

      case 'Down':
        spriteAngle = FireBlock.halfRotation;
        hitboxPosition = Vector2(0, tileSize);
        spritePosition = Vector2(tileSize, tileSize * 2);
        break;

      case 'Left':
        spriteAngle = -FireBlock.halfRotation / 2;
        collisionPosition = Vector2(position.x + tileSize, position.y);
        spritePosition = Vector2(0, tileSize);
        break;

      case 'Right':
        spriteAngle = FireBlock.halfRotation / 2;
        hitboxPosition = Vector2(tileSize, 0);
        spritePosition = Vector2(tileSize * 2, 0);
        break;
    }

    // Sprite correction
    fireSprite.angle = spriteAngle;
    fireSprite.position = spritePosition;
    fireSprite.size = Vector2(16, 32);

    // Collision correction
    collisionBlock.position = collisionPosition;
    collisionBlock.size = Vector2.all(tileSize);

    // Hitbox correction
    attackHitbox.position = hitboxPosition;
    attackHitbox.size = Vector2.all(tileSize);
  }

  void _loadAnimations() {
    onAnimation = _spriteAnimation("On", 3);
    offAnimation = _spriteAnimation("Off", 4);
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fire/$state (16x32).png'),
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: Vector2(tileSize, tileSize * 2)),
    );
  }

  // The "_" ignores the parameter of the function
  void _startPeriodicToggle() {
    _fireBlockCounters[startIn] = (_fireBlockCounters[startIn]! - 1);
    final isFirstInstance = _fireBlockCounters[startIn] == 0;

    timer = async.Timer.periodic(const Duration(seconds: 2), (_) {
      isOn = !isOn;
      if (game.settings.isSoundEnabled && isOn && isFirstInstance) {
        SoundManager().playFire(game.settings.gameVolume);
      }
      fireSprite.current = isOn ? FireBlockState.on : FireBlockState.off;
    });
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      final isPlayerInside = isPlayerInsideBlock(other, attackHitbox);
      if (isOn && isPlayerInside) {
        other.collidedWithEnemy();
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void removeSound(){
    if (timer.isActive) {
      timer.cancel();
    }
  }
}