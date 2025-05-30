import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameText extends TextComponent with HasGameReference {
  GameText({
    required String text,
    required Vector2 position,
    required double maxWidth,
    double fontSize = 16,
    Color color = Colors.white,
    String fontFamily = 'ArcadeClassic',
  }) : super(
         text: text,
         position: position,
         priority: -3,
         textRenderer: TextPaint(
           style: TextStyle(
             fontSize: fontSize,
             fontFamily: fontFamily,
             color: color,
             height: 1.0,
             overflow: TextOverflow.visible,
           ),
         ),
       ) {
    size = Vector2(maxWidth, double.infinity);
  }

  @override
  void onMount() {
    super.onMount();
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 16, fontFamily: 'ArcadeClassic', color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: size.x);
    textPainter.paint(canvas, position.toOffset());
  }
}
