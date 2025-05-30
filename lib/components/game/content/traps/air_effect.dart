import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class AirEffect extends PositionComponent {
  final Paint airPaint = Paint()..color = Colors.cyan.withAlpha((0.4 * 255).toInt());
  double offsetX = 0.0;

  static const double lineSpacing = 6.0;
  static const double lineLength = 10.0;
  static const double lineHeight = 1.5;
  static const double speed = 80.0;

  final List<double> _horizontalOffsets = [];

  AirEffect({required Vector2 size, required Vector2 position}) {
    this.size = size;
    this.position = position;

    for (double y = 0; y < size.y; y += lineSpacing) {
      // This creates a pattern to the air with deviations to the left and right
      final deviation = ((y ~/ lineSpacing) % 2 == 0 ? -1 : 1) * ((y % 4) + 2);
      _horizontalOffsets.add(deviation.toDouble());
    }
  }

  // This method is called when the component is added to the game then it draws the air effect.
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    int row = 0;

    for (double y = 0; y < size.y; y += lineSpacing) {
      final deviation = _horizontalOffsets[row % _horizontalOffsets.length];

      // Creating the air stream effect by drawing horizontal lines
      for (double x = -lineLength; x < size.x; x += 2 * lineLength) {
        final lineX = ((x + offsetX + deviation) % size.x);
        canvas.drawRect(Rect.fromLTWH(lineX, y, lineLength, lineHeight), airPaint);
      }

      row++;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update the offset to create a moving effect.
    offsetX -= speed * dt;
  }
}
