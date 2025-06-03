import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';

import '../../../../../fruit_collector.dart';
import '../../base_widget.dart';
import '../../characters/page/character_selection.dart';
import '../vm/main_menu_vm.dart';
import '../widget/background_gif.dart';
import '../widget/menu_button.dart';


class MainMenu extends StatelessWidget {
  static const String id = 'MainMenu';
  final FruitCollector game;

  const MainMenu({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget<MainMenuVM>(
      model: MainMenuVM(game: game, vsync: TickerProviderStub()),
      onModelReady: (MainMenuVM vm) {
        vm.initialize(context);
      },
      builder: (BuildContext context, MainMenuVM vm, Widget? child) {
        const Color buttonColor = Color(0xFF3A3750);
        const Color borderColor = Color(0xFF5A5672);
        const Color textColor = Color(0xFFE1E0F5);

        final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          minimumSize: const Size(220, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: borderColor, width: 2),
          ),
          elevation: 8,
        );

        final double topPadding = MediaQuery.of(context).padding.top + 18;
        final bool isMobile = vm.isMobile(context);

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
                  shape: const CircleBorder(
                    side: BorderSide(color: Color(0xFF5A5672), width: 2),
                  ),
                ),
                onPressed: vm.toggleVolume,
                icon: Icon(
                  vm.isSoundOn ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: isMobile
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: vm.logoAnimation,
                              child: Text(
                                vm.titleText,
                                textAlign: TextAlign.center,
                                style: TextStyleSingleton()
                                    .style
                                    .copyWith(
                                      fontSize: 48,
                                      color: textColor,
                                      shadows: const [
                                        Shadow(
                                            color: Colors.black,
                                            offset: Offset(3, 3),
                                            blurRadius: 6)
                                      ],
                                    ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            MenuButton(
                              label: vm.continueLabel,
                              icon: Icons.play_arrow,
                              style: buttonStyle,
                              onPressed: vm.onContinuePressed,
                              enabled: !vm.isLoading,
                            ),
                            const SizedBox(height: 12),

                            MenuButton(
                              label: vm.loadGameLabel,
                              icon: Icons.save,
                              style: buttonStyle,
                              onPressed: vm.onLoadGamePressed,
                              enabled: !vm.isLoading,
                            ),
                            const SizedBox(height: 12),

                            MenuButton(
                              label: vm.quitLabel,
                              icon: Icons.exit_to_app,
                              style: buttonStyle,
                              onPressed: vm.onQuitPressed,
                              enabled: !vm.isLoading,
                            ),
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
                                scale: vm.logoAnimation,
                                child: Text(
                                  vm.titleText,
                                  style: TextStyleSingleton()
                                      .style
                                      .copyWith(
                                        fontSize: 48,
                                        color: textColor,
                                        shadows: const [
                                          Shadow(
                                              color: Colors.black,
                                              offset: Offset(3, 3),
                                              blurRadius: 6)
                                        ],
                                      ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              MenuButton(
                                label: vm.continueLabel,
                                icon: Icons.play_arrow,
                                style: buttonStyle,
                                onPressed: vm.onContinuePressed,
                                enabled: !vm.isLoading,
                              ),
                              const SizedBox(height: 12),

                              MenuButton(
                                label: vm.loadGameLabel,
                                icon: Icons.save,
                                style: buttonStyle,
                                onPressed: vm.onLoadGamePressed,
                                enabled: !vm.isLoading,
                              ),
                              const SizedBox(height: 12),

                              MenuButton(
                                label: vm.quitLabel,
                                icon: Icons.exit_to_app,
                                style: buttonStyle,
                                onPressed: vm.onQuitPressed,
                                enabled: !vm.isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}