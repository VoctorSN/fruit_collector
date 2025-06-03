import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class BackgroundWidget extends StatefulWidget {
  const BackgroundWidget({super.key});

  @override
  State<BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget> {
  final List<String> gifPaths = List.generate(7, (i) => 'assets/gifsMainMenu/gif${i + 1}.gif');

  int _currentGif = 0;
  late Timer _gifTimer;
  final Color baseColor = const Color(0xFF212030);

  @override
  void initState() {
    super.initState();
    _gifTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      setState(() {
        _currentGif = (_currentGif + 1) % gifPaths.length;
      });
    });
  }

  @override
  void dispose() {
    _gifTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand, // Ensures the stack fills the available space
      children: [
        Image.asset(gifPaths[_currentGif], fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(color: baseColor.withAlpha(102)),
        ),
      ],
    );
  }
}
