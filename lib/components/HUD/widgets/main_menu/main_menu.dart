import 'dart:io' show Platform, exit;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';

import '../../../../fruit_collector.dart';
import '../../../bbdd/models/game.dart';
import '../../../bbdd/services/game_service.dart';
import 'background_gif.dart';
import 'game_selector.dart';

class MainMenu extends StatefulWidget {
  static const String id = 'MainMenu';
  final FruitCollector game;

  const MainMenu(this.game, {super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;

  final Color baseColor = const Color(0xFF212030);
  final Color buttonColor = const Color(0xFF3A3750);
  final Color borderColor = const Color(0xFF5A5672);
  final Color textColor = const Color(0xFFE1E0F5);

  late final ButtonStyle buttonStyle;

  bool _isSoundOn = true;
  bool isLoading = true;

  late GameService service;
  late Game game;

  bool get isMobile {
    if (kIsWeb) {
      return MediaQuery.of(context).size.width < 600;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void initState() {
    super.initState();
    loadLastGame();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: textColor,
      minimumSize: const Size(220, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor, width: 2),
      ),
      elevation: 8,
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  Widget _menuButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: buttonStyle,
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: Text(label, style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 18;

    return Stack(
      fit: StackFit.expand,
      children: [
        const BackgroundWidget(),

        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: buttonColor,
              shape: const CircleBorder(side: BorderSide(color: Color(0xFF5A5672), width: 2)),
            ),
            onPressed: _onVolumeToggle,
            icon: Icon(_isSoundOn ? Icons.volume_up : Icons.volume_off, color: Colors.white, size: 22),
          ),
        ),

        // Menú principal
        Padding(
          padding: EdgeInsets.only(top: topPadding),
          child:
              isMobile
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _logoController,
                            child: Text(
                              'FRUIT COLLECTOR',
                              textAlign: TextAlign.center,
                              style: TextStyleSingleton().style.copyWith(
                                fontSize: 48,
                                color: textColor,
                                shadows: const [Shadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 6)],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _menuButton('CONTINUE', Icons.play_arrow, _onContinuePressed),
                          const SizedBox(height: 12),
                          _menuButton('LOAD GAME', Icons.save, _onLoadGamePressed),
                          const SizedBox(height: 12),
                          _menuButton('QUIT', Icons.exit_to_app, () {
                            widget.game.soundManager.stopBGM();
                            if (Platform.isWindows) {
                              exit(0);
                            } else {
                              SystemNavigator.pop();
                            }
                          }),
                        ],
                      ),
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.only(left: 34),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaleTransition(
                              scale: _logoController,
                              child: Text(
                                'FRUIT COLLECTOR',
                                style: TextStyleSingleton().style.copyWith(
                                  fontSize: 48,
                                  color: textColor,
                                  shadows: const [Shadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 6)],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _menuButton('CONTINUE', Icons.play_arrow, _onContinuePressed),
                            const SizedBox(height: 12),
                            _menuButton('LOAD GAME', Icons.save, _onLoadGamePressed),
                            const SizedBox(height: 12),
                            _menuButton('QUIT', Icons.exit_to_app, () {
                              widget.game.soundManager.stopBGM();
                              if (Platform.isWindows) {
                                exit(0);
                              } else {
                                SystemNavigator.pop();
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  Future<void> loadLastGame() async {
    service = await GameService.getInstance();
    game = await service.getLastPlayedOrCreate();
    widget.game.isOnMenu = true;
    await widget.game.chargeSlot(game.space);
    setState(() {
      isLoading = false;
      _isSoundOn = widget.game.settings.isMusicActive;
    });
    if (_isSoundOn) {
      widget.game.soundManager.startMenuBGM(widget.game.settings);
    } else {
      widget.game.soundManager.stopBGM();
    }
  }

  void _onVolumeToggle() async {
    setState(() {
      _isSoundOn = !_isSoundOn;
      if (_isSoundOn) {
        widget.game.soundManager.startMenuBGM(widget.game.settings);
      } else {
        widget.game.soundManager.stopBGM();
      }
    });
    widget.game.settings.isMusicActive = _isSoundOn;
    widget.game.settingsService!.updateSettings(widget.game.settings);
  }

  void _onContinuePressed() async {
    if(isLoading) return;
    widget.game.isOnMenu = false;
    widget.game.overlays.remove(MainMenu.id);
    await widget.game.chargeSlot(game.space);
    widget.game.resumeEngine();
    if (_isSoundOn) {
      widget.game.soundManager.startDefaultBGM(widget.game.settings);
    }
  }

  void _onLoadGamePressed() {
    widget.game.overlays.remove(MainMenu.id);
    widget.game.overlays.add(GameSelector.id);
  }
}