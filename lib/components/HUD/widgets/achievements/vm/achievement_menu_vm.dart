import 'package:flutter/material.dart';

class AchievementMenuVM extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  final List<Map<String, dynamic>> achievements;

  AchievementMenuVM({required this.achievements});

  static const double rowHeight = 70;
  static const double rowSpacing = 6;

  void scrollByRow({required bool forward}) {
    final double currentOffset = scrollController.offset;
    final int currentRow = (currentOffset / (rowHeight + rowSpacing)).round();
    final int targetRow = forward ? currentRow + 1 : (currentRow - 1).clamp(0, achievements.length - 1);
    final double targetOffset = targetRow * (rowHeight + rowSpacing);

    scrollController.animateTo(targetOffset, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
