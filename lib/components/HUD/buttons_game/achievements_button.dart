import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../fruit_collector.dart';
import '../widgets/achievements/page/achievements_menu.dart';

class AchievementsButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {

  final double buttonSize;

  AchievementsButton({required this.buttonSize});

  bool isAvaliable = true;

  @override
  FutureOr<void> onLoad() {
    priority = 102;
    sprite = Sprite(game.images.fromCache('GUI/HUD/achievementsButton.png'));
    size = Vector2.all(buttonSize);
    position = Vector2((buttonSize * 2) + 30, 10);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isAvaliable) {
      return;
    }
    game.soundManager.pauseAll();
    game.pauseEngine();
    game.overlays.add(AchievementMenu.id);
    super.onTapDown(event);
  }
}