import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/content/blocks/collision_block.dart';

mixin CollisionableWithHitbox on SpriteAnimationGroupComponent, CollisionCallbacks {
  late RectangleHitbox hitbox;

  bool checkCollision(CollisionBlock block, {Vector2? hitboxOffset}) {
    final hitboxRect = hitbox.toRect();
    final playerX = position.x + (hitboxOffset?.x ?? hitboxRect.left);
    final playerY = position.y + (hitboxOffset?.y ?? hitboxRect.top);
    final playerWidth = hitboxRect.width;
    final playerHeight = hitboxRect.height;

    final blockX = block.x;
    final blockY = block.y;
    final blockWidth = block.width;
    final blockHeight = block.height;

    // Adjust for sprite flip (negative scale)
    final fixedX = scale.x < 0 ? playerX - (hitboxOffset != null ? hitboxOffset.x * 2 : playerWidth) : playerX;

    // Adjust Y for platform collisions
    final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

    return (fixedY < blockY + blockHeight &&
        playerY + playerHeight > blockY &&
        fixedX < blockX + blockWidth &&
        fixedX + playerWidth > blockX);
  }
}
