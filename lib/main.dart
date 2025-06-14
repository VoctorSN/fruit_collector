import 'dart:io';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fruit_collector/fruit_collector.dart';
import 'package:window_size/window_size.dart';

import 'components/game/util/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
flutt
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    setWindowTitle('Fruit Collector');
    setWindowMinSize(const Size(800, 600));
  } else {
    //await NotificationService.instance.initialize();
  }

  FruitCollector game = FruitCollector();
  runApp(GameWidget(game: kDebugMode ? FruitCollector() : game));
}