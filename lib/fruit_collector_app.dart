import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'fruit_collector.dart';

class FruitCollectorApp extends StatelessWidget {
  const FruitCollectorApp({super.key});

  Future<FruitCollector> _loadGame() async {
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();
    final FruitCollector game = FruitCollector();
    await game.onLoad();
    return game;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FruitCollector>(
      future: _loadGame(),
      builder: (BuildContext context, AsyncSnapshot<FruitCollector> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return GameWidget(game: snapshot.data!);
        }

        // Show splash screen while loading
        return const MaterialApp(
          home: Scaffold(
            backgroundColor: Color(0xFF3A3750),
            body: Center(
              child: Image(
                image: AssetImage('assets/images/Main Characters/Mask Dude/jump.png'),
                width: 200,
                height: 200,
                filterQuality: FilterQuality.none,
                isAntiAlias: false,
                fit: BoxFit.fill,
              ),
            ),
          ),
        );
      },
    );
  }
}