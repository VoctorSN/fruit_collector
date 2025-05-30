import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';

import '../../../../fruit_collector.dart';
import '../utils/number_slider.dart';

// Constants to define size and position
const double rowWidth = 475.0;
const double textPositionX = 45.0;
const double sliderPositionX = 20.0;
const double buttonPositionX = 0.0;
const double sliderWidth = 250.0;

class ToggleGameVolumeWidget extends StatefulWidget {
  final FruitCollector game;
  final Function updateGameVolume;

  const ToggleGameVolumeWidget({super.key, required this.game, required this.updateGameVolume});

  @override
  State<ToggleGameVolumeWidget> createState() {
    return _ToggleGameVolumeWidgetState(game: game, updateGameVolume: updateGameVolume);
  }
}

class _ToggleGameVolumeWidgetState extends State<ToggleGameVolumeWidget> {
  final FruitCollector game;
  final Function updateGameVolume;

  _ToggleGameVolumeWidgetState({required this.game, required this.updateGameVolume})
    : isSliderActive = game.settings.isSoundEnabled;

  bool isMuted = false;
  late double value;
  bool isSliderActive;

  Image get volumeImage {
    return game.settings.isSoundEnabled
        ? Image.asset('assets/images/GUI/HUD/soundOnButton.png', fit: BoxFit.cover)
        : Image.asset('assets/images/GUI/HUD/soundOffButton.png', fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rowWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: textPositionX),
          Text('Volume', style: TextStyleSingleton().style),
          const SizedBox(width: sliderPositionX),
          SizedBox(
            width: sliderWidth,
            child: NumberSlider(
              game: game,
              value: game.settings.gameVolume * 50,
              onChanged: onChanged,
              isActive: isSliderActive,
            ),
          ),
          const SizedBox(width: buttonPositionX),
          IconButton(onPressed: changeState, icon: volumeImage),
        ],
      ),
    );
  }

  double? onChanged(dynamic value) {
    if (!game.settings.isSoundEnabled) {
      return null;
    }

    updateGameVolume(value / 50);
    return value;
  }

  void changeState() {
    setState(() {
      game.settings.isSoundEnabled = !game.settings.isSoundEnabled;
      isSliderActive = !isSliderActive;
    });
  }
}
