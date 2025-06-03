import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';

import '../../../../bbdd/models/game.dart';

/// Stateless widget that renders a single save-slot button,
/// showing "Empty" or "SAVE SLOT X - Level Y" and a delete icon if not empty.
class SlotButton extends StatelessWidget {
  final Game? gameSlot;
  final int slotNumber;
  final Color textColor;
  final ButtonStyle style;
  final VoidCallback onPressed;
  final VoidCallback onDelete;

  const SlotButton({
    required this.gameSlot,
    required this.slotNumber,
    required this.textColor,
    required this.style,
    required this.onPressed,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = gameSlot == null;
    final String label = isEmpty
        ? 'EMPTY'
        : 'SAVE SLOT $slotNumber - LEVEL ${gameSlot!.currentLevel + 1}';
    final IconData icon = isEmpty
        ? Icons.insert_drive_file_outlined
        : Icons.insert_drive_file;

    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 12),

          // Label text
          Expanded(
            child: Text(
              label,
              style: TextStyleSingleton()
                  .style
                  .copyWith(
                    fontSize: 14,
                    color:
                        textColor.withAlpha(isEmpty ? 102 : 255),
                  ),
            ),
          ),

          // Show delete icon only if slot is not empty
          if (!isEmpty)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(38),
                  border: Border.all(color: const Color.fromARGB(255, 199, 89, 89)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Color.fromARGB(255, 199, 89, 89), size: 18),
              ),
            ),
        ],
      ),
    );
  }
}