import 'package:flame/components.dart';

import '../levelBasics/player.dart';

mixin PlayerCollidable on SpriteAnimationGroupComponent {
  late final Player player;

  void collidedWithPlayer() {
    player.collidedWithEnemy();
  }
}
