import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:fruit_collector/fruit_collector.dart';

class ConfettiEmitterComponent extends Component with HasGameReference<FruitCollector> {
  final Vector2 origin;
  final int count;
  final double lifespan;

  ConfettiEmitterComponent({required this.origin, this.count = 30, this.lifespan = 1.5});

  @override
  Future<void> onLoad() async {
    final random = Random();
    priority = 5;
    final sprite = await game.loadSprite('Other/Confetti (16x16).png');
    final particle = Particle.generate(
      count: count,
      lifespan: lifespan,
      generator: (_) {
        final initialVelocity = Vector2(
          (random.nextDouble() - 0.5) * 200, // random horizontal velocity
          -random.nextDouble() * 300, // upward velocity
        );

        return AcceleratedParticle(
          acceleration: Vector2(0, 300), // gravity
          speed: initialVelocity,
          child: SpriteParticle(sprite: sprite, size: Vector2.all(8)),
        );
      },
    );

    final system = ParticleSystemComponent(particle: particle, position: origin.clone());

    game.level.add(system);
  }
}
