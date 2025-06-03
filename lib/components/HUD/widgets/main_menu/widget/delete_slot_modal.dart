import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';

/// Stateless widget that shows a confirmation modal to delete a save slot.
class DeleteSlotModal extends StatelessWidget {
  final int slotNumber;
  final Color textColor;
  final Color baseColor;
  final Color borderColor;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const DeleteSlotModal({
    required this.slotNumber,
    required this.textColor,
    required this.baseColor,
    required this.borderColor,
    required this.onCancel,
    required this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(153),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 360,
          decoration: BoxDecoration(
            color: baseColor.withAlpha(242),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal title
              Text(
                'DELETE SLOT $slotNumber',
                style: TextStyleSingleton()
                    .style
                    .copyWith(fontSize: 22, color: Colors.redAccent),
              ),
              const SizedBox(height: 16),

              // Confirmation message
              Text(
                'ARE YOU SURE YOU WANT TO DELETE THIS SLOT?\nTHIS ACTION CANNOT BE UNDONE.',
                textAlign: TextAlign.center,
                style: TextStyleSingleton()
                    .style
                    .copyWith(fontSize: 14, color: textColor),
              ),
              const SizedBox(height: 24),

              // Cancel and Confirm buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel button
                  ElevatedButton.icon(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: borderColor),
                      ),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: Text(
                      'CANCEL',
                      style:
                          TextStyleSingleton().style.copyWith(fontSize: 14),
                    ),
                  ),

                  // Confirm delete button
                  ElevatedButton.icon(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: borderColor),
                      ),
                    ),
                    icon: const Icon(Icons.delete_forever, size: 16),
                    label: Text(
                      'DELETE',
                      style:
                          TextStyleSingleton().style.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}