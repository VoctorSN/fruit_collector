import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/levelBasics/player.dart';

class DeathZone extends PositionComponent with CollisionCallbacks {
  // Constructor
  DeathZone({required Vector2 position, required Vector2 size}) {
    this.position = position;
    this.size = size;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(
      RectangleHitbox()
        ..collisionType = CollisionType.active
        ..position = position
        ..size = size,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) other.collidedWithEnemy();
    super.onCollision(intersectionPoints, other);
  }
}
