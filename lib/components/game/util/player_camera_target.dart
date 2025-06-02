import 'package:flame/components.dart';

import '../content/levelBasics/player.dart';

class PlayerCameraTarget extends PositionComponent {
  final Player player;

  PlayerCameraTarget({required this.player}) : super(priority: 99);

  @override
  void update(double dt) {
    // Calculate horizontal center considering player direction and hitbox
    final hitbox = player.hitbox;
    final baseX = player.position.x + hitbox.offsetX;
    final width = hitbox.width;

    final centerX = player.scale.x < 0
        ? baseX - (hitbox.offsetX * 2) - width / 2
        : baseX + width / 2;

    // Calculate vertical center of the hitbox
    final centerY = player.position.y + hitbox.offsetY + hitbox.height / 2;

    position = Vector2(centerX, centerY);

    super.update(dt);
  }
}