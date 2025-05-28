import 'dart:async' as async;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../util/utils.dart';
import '../levelBasics/player.dart';
import 'collision_block.dart';

class AlternatingBlock extends CollisionBlock with HasGameReference<PixelAdventure> {
  // Constructor
  AlternatingBlock({required this.isRed, super.position, super.size});

  bool isRed;

  // Loading sprites
  late SpriteComponent spriteComponent;
  late Sprite blockActive;
  late Sprite blockInactive;

  // Logic to switch between active and inactive blocks
  static bool isRedActive = true;
  static bool _timerStarted = false;
  static final List<AlternatingBlock> _instances = [];

  // Logic to handle collision
  late RectangleHitbox hitbox;
  bool isActive = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    priority = 0;

    _loadSprites();

    hitbox = RectangleHitbox(size: Vector2(size.x, size.y), position: Vector2.zero());
    add(hitbox);

    spriteComponent = SpriteComponent(sprite: blockActive, size: Vector2(size.x, size.y), position: Vector2.zero());

    add(spriteComponent);

    _instances.add(this);

    if (!_timerStarted) {
      _startPeriodicToggle();
    }
    _updateSprite();
  }

  void _loadSprites() {
    if (isRed) {
      blockActive = _getTile(9, 2);
      blockInactive = _getTile(10, 2);
    } else {
      blockActive = _getTile(9, 6);
      blockInactive = _getTile(10, 6);
    }
  }

  Sprite _getTile(int col, int row) {
    final spriteSheet = game.images.fromCache('Terrain/Terrain (16x16).png');
    return Sprite(spriteSheet, srcPosition: Vector2(col * 16.0, row * 16.0), srcSize: Vector2.all(16));
  }

  void _startPeriodicToggle() {
    _timerStarted = true;
    async.Timer.periodic(const Duration(seconds: 1), (async.Timer timer) {
      isRedActive = !isRedActive;
      for (final block in _instances) {
        block._updateSprite();
      }
    });
  }

  void _updateSprite() {
    isActive = isRed == isRedActive;
    spriteComponent.sprite = isActive ? blockActive : blockInactive;
    hitbox.collisionType = isActive ? CollisionType.active : CollisionType.inactive;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      if (isActive && isPlayerInsideBlock(other, hitbox)) {
        movePlayerNextToBlock(other, hitbox);
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}