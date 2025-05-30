import 'package:flame/components.dart';
import 'package:fruit_collector/fruit_collector.dart';

class LoadingBanana extends SpriteAnimationComponent with HasGameReference<FruitCollector> {
  @override
  final FruitCollector game;

  LoadingBanana(this.game) : super(priority: 10);

  late final buttonSize = game.settings.hudSize;

  Future<void> show() async {
    priority = 100;

    final image = game.images.fromCache('loadingBanana/loadingBanana.png');

    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(amount: 9, stepTime: 0.25, loop: false, textureSize: Vector2.all(32)),
    );

    size = Vector2.all(buttonSize);
    position = Vector2(game.size.x - buttonSize * 2 - 20, 10);

    game.add(this);

    await animationTicker?.completed;
    removeFromParent();
  }

  @override
  void onGameResize(Vector2 size) {
    position = Vector2(game.size.x - buttonSize * 2 - 20, 10);
    super.onGameResize(size);
  }
}
