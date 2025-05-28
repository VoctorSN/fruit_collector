import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../../fruit_collector.dart';
import '../../../bbdd/models/levelModel.dart';

enum TransitionPhase { contracting, expanding, idle }

class ChangeLevelScreen extends PositionComponent with HasGameReference<PixelAdventure> {
  final double durationMs;
  final VoidCallback onExpandEnd;

  late double radius;
  double _elapsed = 0.0;
  TransitionPhase _phase = TransitionPhase.idle;

  late final double maxRadius;
  late final Vector2 center;
  bool endFunctionExecuted = false;
  bool showLevelSummary = true;

  ChangeLevelScreen({required this.onExpandEnd, this.durationMs = 800}) : super(priority: 3000);

  @override
  Future<void> onLoad() async {
    center = game.size / 2;
    maxRadius = game.size.length;
    radius = maxRadius;
    startContract();
  }

  @override
  void render(Canvas canvas) {
    final Size screenSize = game.size.toSize();
    final Path path = Path()..addRect(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height));
    path.addOval(Rect.fromCircle(center: Offset(center.x, center.y), radius: radius));
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.95));
  }

  @override
  void update(double dt) {
    if (_phase == TransitionPhase.idle) return;

    _elapsed += dt * 1000;
    final progress = (_elapsed / durationMs).clamp(0.0, 1.0);
    final eased = progress * (2 - progress); // easeOutQuad

    if (_phase == TransitionPhase.contracting) {
      radius = maxRadius * (1 - eased);

      if (progress >= 1.0) {
        radius = 0.0;
        _phase = TransitionPhase.idle;
        showLevelSummary ? game.overlays.add('level_summary') : game.changeLevelScreen.startExpand();
        game.removeWhere((component) => component is Level);
      }
    } else if (_phase == TransitionPhase.expanding) {
      if (!endFunctionExecuted) {

        onExpandEnd();
        endFunctionExecuted = true;
      }
      radius = maxRadius * eased;

      if (progress >= 1.0) {
        radius = maxRadius;
        _phase = TransitionPhase.idle;
        removeFromParent();
      }
    }
  }

  void startContract() {
    game.toggleBlockButtons(false);
    game.toggleBlockWindowResize(false);
    _elapsed = 0.0;
    radius = maxRadius;
    _phase = TransitionPhase.contracting;
  }

  void startExpand() {
    _elapsed = 0.0;
    radius = 0.0;
    _phase = TransitionPhase.expanding;
    game.toggleBlockButtons(true);
    game.toggleBlockWindowResize(true);
  }

  @override
  bool get isHud => true;
}
