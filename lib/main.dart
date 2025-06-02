import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'fruit_collector_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    setWindowTitle('Fruit Collector');
    setWindowMinSize(const Size(800, 600));
  }

  debugDefaultTargetPlatformOverride = TargetPlatform.android;

  runApp(const FruitCollectorApp());
}