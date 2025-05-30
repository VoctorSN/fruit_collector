import 'dart:async' as async;
import 'dart:async';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../level/sound_manager.dart';
import '../../util/utils.dart';
import '../levelBasics/player.dart';

enum GhostState { appearing, moving, disappearing }

class Ghost extends SpriteAnimationGroupComponent
    with CollisionCallbacks, HasGameReference<FruitCollector> {

  // Constructor and attributes
  final int spawnIn;
  final Vector2 initialPosition;
  Ghost({super.position, super.size, this.spawnIn = 0})
    : initialPosition = position!.clone();

  // Animation
  late final SpriteAnimation _appearingAnimation;
  late final SpriteAnimation _movingAnimation;
  late final SpriteAnimation _disappearingAnimation;
  static final Vector2 spriteSize = Vector2(44, 30);
  static const double stepTime = 0.1;

  // Particles
  late final List<Sprite> trailSprites;
  double _timeSinceLastParticle = 0.0;
  static const double _particleInterval = 0.2;

  // Movement
  late final Player player = game.player;
  final double speed = 0.5;
  bool isLookingRight = false;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  // Sound
  bool _isActive = true;

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Ghost/$state (44x30).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: spriteSize,
      ),
    );
  }

  @override
  FutureOr<void> onLoad() async {
    add(RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26)));
    _loadAllAnimations();
    await _loadTrailSprites();

    async.Future.delayed(Duration(seconds: spawnIn), _spawn);
    return super.onLoad();
  }

  @override
  void onRemove() {
    _isActive = false;
    super.onRemove();
  }

  Future<void> _loadTrailSprites() async {
    final image = game.images.fromCache(
      'Enemies/Ghost/Gost Particles (48x16).png',
    );
    trailSprites = List.generate(
      4,
      (i) => Sprite(
        image,
        srcPosition: Vector2(16.0 * i, 0),
        srcSize: Vector2(16, 16),
      ),
    );
  }

  void _spawn() async {
    if (!_isActive) return;

    if (game.settings.isSoundEnabled) {
      SoundManager().playAppearGhost(game.settings.gameVolume);
    }
    current = GhostState.appearing;
    await animationTicker?.completed;
    if (!_isActive) return;
    current = GhostState.moving;
  }

  void respawn() async {
    if (!_isActive) return;

    if (game.settings.isSoundEnabled) {
      SoundManager().playDisappearGhost(game.settings.gameVolume);
    }
    current = GhostState.disappearing;
    await animationTicker?.completed;
    if (!_isActive) return;
    position = initialPosition;

    async.Future.delayed(const Duration(seconds: 2), () {
      if (_isActive) _spawn();
    });
  }

  void _loadAllAnimations() {
    _appearingAnimation = _spriteAnimation('Appear', 4)..loop = false;
    _movingAnimation = _spriteAnimation('Idle', 10);
    _disappearingAnimation = _spriteAnimation('Disappear', 4)..loop = false;

    animations = {
      GhostState.appearing: _appearingAnimation,
      GhostState.moving: _movingAnimation,
      GhostState.disappearing: _disappearingAnimation,
    };
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (current == GhostState.moving) {
        _move(fixedDeltaTime);
        _emitTrailParticle(fixedDeltaTime);
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);

  }

  void _emitTrailParticle(double dt) {
    _timeSinceLastParticle += dt;
    if (_timeSinceLastParticle < _particleInterval) return;
    _timeSinceLastParticle = 0;

    final particle = ParticleSystemComponent(
      position: position.clone() + size / 2,
      priority: -1,
      particle: Particle.generate(
        count: 1,
        lifespan: 0.8,
        generator:
            (i) => AcceleratedParticle(
              acceleration: Vector2(0, 5),
              speed: Vector2.random() * 10 - Vector2.all(5),
              position: Vector2(
                isLookingRight ? -size.x : 0,
                (math.Random().nextDouble() * 20 - 10),
              ),
              child: SpriteParticle(
                sprite: trailSprites[i % trailSprites.length],
                size: Vector2(16, 16),
              ),
            ),
      ),
    );

    parent?.add(particle);
  }

  void _move(double dt) {
    // Calculate player's X position once
    final playerX = getPlayerXPosition(player);
    final threshold = 10.0; // Threshold for X movement
    double playerCenter = playerX + player.hitbox.width / 2;
    double ghostCenter = position.x + ((scale.x > 0) ? width : -width) / 2;

    // X movement and direction
    if (playerCenter > ghostCenter + threshold && !isLookingRight) {
      lookRight();
    } else if (playerCenter + threshold < ghostCenter && isLookingRight) {
      lookLeft();
    }
    position.x += speed * (playerCenter - ghostCenter).sign;

    position.y += speed * (player.position.y - position.y).sign;
  }

  void lookLeft() {
    flipHorizontallyAroundCenter();
    isLookingRight = false;
  }

  void lookRight() {
    flipHorizontallyAroundCenter();
    isLookingRight = true;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && current == GhostState.moving) {
      other.collidedWithEnemy();
    }
    if (other is Ghost &&
        position.x < other.position.x &&
        current == GhostState.moving) {
      respawn();
    }
    super.onCollision(intersectionPoints, other);
  }
}