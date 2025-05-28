import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:fruit_collector/components/game/content/blocks/collision_block.dart';
import 'package:fruit_collector/components/game/content/enemies/bee.dart';
import 'package:fruit_collector/fruit_collector.dart';

import '../../levelBasics/player.dart';

class BeeProjectile extends SpriteComponent
    with CollisionCallbacks, HasGameReference<PixelAdventure> {
  final Vector2 velocity;
  Function(dynamic) addSpawnPoint;

  BeeProjectile({
    required Vector2 super.position,
    required Vector2 super.size,
    required this.velocity,
    required this.addSpawnPoint,
  });

  late final Player player;
  static final double lifeSpan = 0.5;
  static final Vector2 particleSize = Vector2.all(24);

  @override
  Future<void> onLoad() async {
    player = game.player;
    await super.onLoad();
    sprite = await game.loadSprite('Enemies/Bee/Bullet.png');
    priority = 5;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Bee){
      return;
    }
    if (other is Player) {
      other.collidedWithEnemy();
      destroyWithParticles();
    }

    if(other is CollisionBlock){
      destroyWithParticles();
    }
    super.onCollision(intersectionPoints, other);
  }

  void destroyWithParticles() async {
    final sprite = await game.loadSprite('Enemies/Bee/Bullet Pieces.png');
    final particle = ParticleSystemComponent(
      particle: Particle.generate(
        lifespan: lifeSpan,
        generator:
            (i) => AcceleratedParticle(
              position: position,
              speed: Vector2.random() * 20 - Vector2.all(10),
              child: SpriteParticle(
                sprite: sprite,
                size: particleSize, // Tamaño de cada fragmento
              ),
            ),
      ),
    );

    removeFromParent();
    addSpawnPoint(particle);
  }
}