import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';

import '../../../../../fruit_collector.dart';
import '../../base_widget.dart';
import '../vm/game_selector_vm.dart';
import '../widget/background_gif.dart';
import '../widget/delete_slot_modal.dart';
import '../widget/slot_button.dart';

class GameSelector extends StatelessWidget {
  static const String id = 'GameSelector';
  final FruitCollector game;

  const GameSelector({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget<GameSelectorVM>(
      // Instantiate the ViewModel, passing the game reference
      model: GameSelectorVM(game: game),
      onModelReady: (GameSelectorVM vm) {
        // Load saved game slots once VM is ready
        vm.loadSlots();
      },
      builder: (BuildContext context, GameSelectorVM vm, Widget? child) {
        // Define common colors and styles
        const Color baseColor = Color(0xFF212030);
        const Color buttonColor = Color(0xFF3A3750);
        const Color borderColor = Color(0xFF5A5672);
        const Color textColor = Color(0xFFE1E0F5);

        final ButtonStyle slotButtonStyle = ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          minimumSize: const Size(220, 48),
          maximumSize: const Size(250, 48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: borderColor, width: 2),
          ),
          elevation: 6,
        );

        final ButtonStyle backButtonStyle = ElevatedButton.styleFrom(
          backgroundColor: baseColor.withAlpha(178),
          foregroundColor: textColor,
          minimumSize: const Size(140, 40),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: borderColor, width: 1),
          ),
          elevation: 4,
        );

        // Calculate top padding to avoid status bar overlap
        final double topPadding = MediaQuery.of(context).padding.top + 18;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Background GIF widget
            const BackgroundWidget(),

            // Main selector container
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: 400,
                    decoration: BoxDecoration(
                      color: baseColor.withAlpha(191),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title text
                        Text(
                          vm.titleText,
                          textAlign: TextAlign.center,
                          style: TextStyleSingleton()
                              .style
                              .copyWith(
                                fontSize: 32,
                                color: textColor,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                        ),
                        const SizedBox(height: 24),

                        // Slot 1 button
                        SlotButton(
                          gameSlot: vm.slot1,
                          slotNumber: 1,
                          textColor: textColor,
                          style: slotButtonStyle,
                          onPressed: () => vm.selectSlot(1),
                          onDelete: () => vm.confirmDelete(1),
                        ),
                        const SizedBox(height: 5),

                        // Slot 2 button
                        SlotButton(
                          gameSlot: vm.slot2,
                          slotNumber: 2,
                          textColor: textColor,
                          style: slotButtonStyle,
                          onPressed: () => vm.selectSlot(2),
                          onDelete: () => vm.confirmDelete(2),
                        ),
                        const SizedBox(height: 5),

                        // Slot 3 button
                        SlotButton(
                          gameSlot: vm.slot3,
                          slotNumber: 3,
                          textColor: textColor,
                          style: slotButtonStyle,
                          onPressed: () => vm.selectSlot(3),
                          onDelete: () => vm.confirmDelete(3),
                        ),
                        const SizedBox(height: 24),

                        // Back button to return to main menu
                        ElevatedButton(
                          onPressed: vm.goBackToMainMenu,
                          style: backButtonStyle,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_back, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                vm.backLabel,
                                style: TextStyleSingleton()
                                    .style
                                    .copyWith(fontSize: 13, color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Delete confirmation modal (shown only if slotToDelete != null)
            if (vm.slotToDelete != null)
              DeleteSlotModal(
                slotNumber: vm.slotToDelete!,
                textColor: textColor,
                baseColor: baseColor,
                borderColor: borderColor,
                onCancel: vm.cancelDelete,
                onConfirm: () async {
                  await vm.deleteSlot(vm.slotToDelete!);
                },
              ),
          ],
        );
      },
    );
  }
}