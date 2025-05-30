import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/components/game/level/sound_manager.dart';

import '../../../../fruit_collector.dart';

class DeathScreen extends RectangleComponent {
  final Function gameAdd;
  final Function gameRemove;
  final FruitCollector game;

  DeathScreen({
    required this.gameAdd,
    required this.gameRemove,
    required super.size,
    required this.game,
    required super.position,
  });

  final random = Random();

  late RectangleComponent blackScreen;

  late TextComponent? defeatedTextComponent; // Store as class variable
  late TextComponent? defeatedTextShadow; // Store as class variable
  late List<TextComponent> xComponents = []; // Store "X" components

  Future<void> addBlackScreen(int deaths) async {
    game.duringBlackScreen = true;
    game.toggleBlockButtons(false);
    game.toggleBlockWindowResize(false);
    if (game.settings.isSoundEnabled) {
      SoundManager().playGlitch(game.settings.gameVolume);
    }

    final xCount = deaths;
    blackScreen = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF000000).withAlpha(255),
      priority: 1000,
    );

    // Create the "DEFEATED" text component with initial transparency
    defeatedTextComponent = TextComponent(
      text: 'DEFEATED',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          fontFamily: 'ArcadeClassic',
        ),
      ),

      anchor: Anchor.center,
      position: size / 2,
      priority: 1001,
    );
    defeatedTextShadow = TextComponent(
      text: 'DEFEATED',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          fontFamily: 'ArcadeClassic',
        ),
      ),

      anchor: Anchor.center,
      position:
          (size / 2)
            ..x -= 2
            ..y += 2,
      priority: 1000,
    );

    // Create a list to hold the "X" text components
    xComponents.clear(); // Clear previous instances
    final random = Random();
    for (int i = 0; i < xCount; i++) {
      final xComponent = TextComponent(
        text: 'X',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color.fromARGB(255, 224, 119, 119),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'ArcadeClassic',
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(random.nextDouble() * size.x, random.nextDouble() * size.y),
        priority: 999,
      );
      xComponents.add(xComponent);
    }

    // Add the blackScreen and all text components to the game
    gameAdd(blackScreen);
    blackScreen.add(defeatedTextComponent!);
    blackScreen.add(defeatedTextShadow!);
    for (var xComponent in xComponents) {
      blackScreen.add(xComponent);
    }

    // Fade-in effect with text opacity transition
    final totalSteps = (255 / 15).ceil();
    for (int step = 0; step <= totalSteps; step++) {
      final alpha = (step * 15).clamp(0, 255);
      final t = alpha / 255;

      // Update blackScreen opacity
      blackScreen.paint.color = const Color(0xFF000000).withAlpha(alpha);

      // Update "DEFEATED" text opacity
      final defeatedTextColor = Colors.red.withAlpha((255 * t).round().clamp(0, 255));
      final defeatedShadowColor = Colors.white.withAlpha((255 * t).round().clamp(0, 255));

      if (defeatedTextComponent != null) {
        defeatedTextComponent!.textRenderer = TextPaint(
          style: TextStyle(
            color: defeatedTextColor,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'ArcadeClassic',
          ),
        );
        defeatedTextShadow!.textRenderer = TextPaint(
          style: TextStyle(
            color: defeatedShadowColor,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'ArcadeClassic',
          ),
        );
      }

      // Update "X" text opacity
      for (var xComponent in xComponents) {
        final xTextColor = const Color.fromARGB(255, 224, 119, 119).withAlpha((255 * t).round().clamp(0, 255));
        xComponent.textRenderer = TextPaint(
          style: TextStyle(color: xTextColor, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'ArcadeClassic'),
        );
      }

      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Ensure final state
    blackScreen.paint.color = Colors.black;
    if (defeatedTextComponent != null) {
      defeatedTextComponent!.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          fontFamily: 'ArcadeClassic',
        ),
      );
      defeatedTextShadow!.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          fontFamily: 'ArcadeClassic',
        ),
      );
      for (var xComponent in xComponents) {
        xComponent.textRenderer = TextPaint(
          style: const TextStyle(
            color: Color.fromARGB(255, 224, 119, 119),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'ArcadeClassic',
          ),
        );
      }
    }
    game.duringBlackScreen = false;
    game.duringRemovingBlackScreen = true;
    removeBlackScreen();
  }

  Future<void> removeBlackScreen() async {
    await Future.delayed(const Duration(seconds: 1));
    final totalSteps = (255 / 15).ceil();
    for (int step = totalSteps; step >= 0; step--) {
      final alpha = (step * 15).clamp(0, 255);
      final t = alpha / 255;

      // Update blackScreen opacity
      blackScreen.paint.color = const Color(0xFF000000).withAlpha(alpha);

      // Update "DEFEATED" text opacity
      if (defeatedTextComponent != null) {
        final defeatedTextColor = Colors.red.withAlpha((255 * t).round().clamp(0, 255));
        defeatedTextComponent!.textRenderer = TextPaint(
          style: TextStyle(
            color: defeatedTextColor,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'ArcadeClassic',
          ),
        );
      }

      // Update "DEFEATED" text opacity
      if (defeatedTextShadow != null) {
        final defeatedShadowColor = Colors.white.withAlpha((255 * t).round().clamp(0, 255));
        defeatedTextShadow!.textRenderer = TextPaint(
          style: TextStyle(
            color: defeatedShadowColor,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'ArcadeClassic',
          ),
        );
      }

      // Update "X" text opacity
      for (var xComponent in xComponents) {
        final xTextColor = const Color.fromARGB(255, 224, 119, 119).withAlpha((255 * t).round().clamp(0, 255));
        xComponent.textRenderer = TextPaint(
          style: TextStyle(color: xTextColor, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'ArcadeClassic'),
        );
      }

      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Clean up
    if (defeatedTextComponent != null) defeatedTextComponent!.removeFromParent();
    if (defeatedTextShadow != null) defeatedTextShadow!.removeFromParent();

    for (var xComponent in xComponents) {
      xComponent.removeFromParent();
    }
    blackScreen.removeFromParent();
    defeatedTextComponent = null;
    defeatedTextShadow = null;

    xComponents.clear();
    gameRemove(blackScreen);
    game.toggleBlockWindowResize(true);
    game.toggleBlockButtons(true);
    game.duringRemovingBlackScreen = false;
  }
}
