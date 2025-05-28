import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';
import 'package:fruit_collector/fruit_collector.dart';

class Stars extends SpriteAnimationComponent with HasGameReference<PixelAdventure>, CollisionCallbacks {

  // Constructor and attributes
  final String name;
  Stars({this.name = '1', super.position, super.size});

  // Animations logic
  final double stepTime = 0.05;
  bool collected = false;

  // Game logic
  static const int maxStarsPerLevel = 3;

  @override
  FutureOr<void> onLoad() {
    priority = -2;
    add(RectangleHitbox(collisionType: CollisionType.passive));
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Gems/$name.png'),
      SpriteAnimationData.sequenced(amount: 7, stepTime: stepTime, textureSize: Vector2.all(16)),
    );
    return super.onLoad();
  }

  void collidedWithPlayer() async {
    if (!collected) {
      collected = true;

      if (game.settings.isSoundEnabled) {
        SoundManager().playCollectFruit(game.settings.gameVolume);
      }

      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );

      final previousBest = game.level.getStars();
      game.level.starCollected();
      final newStars = game.level.getActualStars();

      print('Stars collected: $newStars, Previous best: $previousBest');

      if (newStars > previousBest && newStars <= maxStarsPerLevel) {
        game.level.levelData!.stars = newStars;
      }

      await animationTicker?.completed;
      removeFromParent();
    }
  }

}