import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../level/level.dart';

class Checkpoint extends SpriteAnimationComponent with HasGameReference<FruitCollector>, CollisionCallbacks {
  final bool isLastLevel;

  Checkpoint({super.position, super.size, required this.isLastLevel});

  // Animations logic
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _flagOutAnimation;
  late final SpriteAnimation _noFlagAnimation;

  bool get isAble {
    return game.children.query<Level>().first.checkpointEnabled();
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(position: Vector2(18, 16), size: Vector2(12, 48), collisionType: CollisionType.passive));
    priority = -1;
    _loadAllAnimations();

    animation = _noFlagAnimation;
    return super.onLoad();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && isAble) _reachedCheckpoint();
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckpoint() async {
    game.level.stopLevelTimer();

    animation = _flagOutAnimation;

    await animationTicker?.completed;
    animationTicker?.reset();
    animation = _idleAnimation;
  }

  void _loadAllAnimations() {
    String route = "Items/Checkpoints/End/End ";
    if (isLastLevel) {
      _idleAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('$route(Idle).png'),
        SpriteAnimationData.sequenced(amount: 1, stepTime: 1, loop: false, textureSize: Vector2.all(64)),
      );
      _flagOutAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('$route(Pressed) (64x64).png'),
        SpriteAnimationData.sequenced(amount: 8, stepTime: 0.08, loop: false, textureSize: Vector2.all(64)),
      );
      _noFlagAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('$route(Idle).png'),
        SpriteAnimationData.sequenced(amount: 1, stepTime: 1, loop: false, textureSize: Vector2.all(64)),
      );
    } else {
      route = "Items/Checkpoints/Checkpoint/Checkpoint ";
      _idleAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('$route(Flag Idle)(64x64).png'),
        SpriteAnimationData.sequenced(amount: 10, stepTime: 0.05, textureSize: Vector2.all(64)),
      );
      _flagOutAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('$route(Flag Out) (64x64).png'),
        SpriteAnimationData.sequenced(amount: 26, stepTime: 0.05, loop: false, textureSize: Vector2.all(64)),
      );
      _noFlagAnimation = SpriteAnimation.fromFrameData(
        game.images.fromCache('$route(No Flag).png'),
        SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: Vector2.all(64)),
      );
    }
  }
}
