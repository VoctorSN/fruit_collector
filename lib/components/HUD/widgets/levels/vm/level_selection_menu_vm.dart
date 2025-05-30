import 'package:flutter/material.dart';

class LevelSelectionMenuVM extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();

  static const double cardSpacing = 12;

  void scrollByRow({required bool forward, required double rowSize}) {
    final double rowHeight = rowSize + cardSpacing;
    final double currentOffset = scrollController.offset;
    final int currentRow = (currentOffset / rowHeight).round();
    final int targetRow = forward ? currentRow + 1 : (currentRow - 1).clamp(0, double.infinity).toInt();
    final double targetOffset = targetRow * rowHeight;

    scrollController.animateTo(targetOffset, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
