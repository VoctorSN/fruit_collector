import 'dart:io';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/fruit_collector.dart';
import 'package:window_size/window_size.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    setWindowTitle('Fruit Collector');
    setWindowMinSize(const Size(800, 600));
  }

  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  PixelAdventure game = PixelAdventure();
  runApp(
      GameWidget(
        game:kDebugMode
            ? PixelAdventure()
            : game,

  ));
}