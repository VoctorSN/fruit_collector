import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../fruit_collector.dart';
import '../../style/text_style_singleton.dart';
import '../utils/number_slider.dart';

// Constantes para definir el tamaño y la posición
const double rowWidth = 475.0;
const double textPositionX = 37.5;
const double sliderPositionX = 17.5;
const double sliderWidth = 250.0;

class ResizeHUD extends StatefulWidget {
  final PixelAdventure game;
  final Function updateSizeHUD;

  ResizeHUD({
    super.key,
    required this.game,
    required this.updateSizeHUD,
  });

  @override
  State<ResizeHUD> createState() {
    return _ResizeHUDState(
      game: game,
      updateSizeHUD: updateSizeHUD,
    );
  }
}

class _ResizeHUDState extends State<ResizeHUD> {
  final PixelAdventure game;
  final Function updateSizeHUD;

  _ResizeHUDState({
    required this.game,
    required this.updateSizeHUD,
  });

  late double value;

  @override
  Widget build(BuildContext context) {
    value = game.settings.hudSize;

    return SizedBox(
      width: rowWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: textPositionX),
          Text(
            'HUD Size',
            style: TextStyleSingleton().style,
          ),
          const SizedBox(width: sliderPositionX),
          SizedBox(
            width: sliderWidth,
            child: NumberSlider(
              minValue: 15.0,
              game: game,
              value: value,
              onChanged: onChanged,
              isActive: true,
            ),
          ),
        ],
      ),
    );
  }

  double? onChanged(dynamic value) {
    updateSizeHUD(value);
    return value;
  }
}