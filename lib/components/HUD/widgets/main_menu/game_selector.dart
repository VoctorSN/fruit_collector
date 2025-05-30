import 'package:flutter/material.dart';
import 'package:fruit_collector/components/HUD/style/text_style_singleton.dart';

import '../../../../fruit_collector.dart';
import '../../../bbdd/models/game.dart';
import '../../../bbdd/services/game_service.dart';
import 'background_gif.dart';
import 'main_menu.dart';

class GameSelector extends StatefulWidget {
  static const String id = 'GameSelector';
  final FruitCollector game;

  const GameSelector(this.game, {super.key});

  @override
  State<GameSelector> createState() => _GameSelectorState();
}

class _GameSelectorState extends State<GameSelector> {
  Game? slot1;
  Game? slot2;
  Game? slot3;

  GameService? gameService;

  int? slotToDelete;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    await getGameService();
    slot1 = await gameService!.getGameBySpace(space: 1);
    slot2 = await gameService!.getGameBySpace(space: 2);
    slot3 = await gameService!.getGameBySpace(space: 3);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = const Color(0xFF212030);
    final Color buttonColor = const Color(0xFF3A3750);
    final Color borderColor = const Color(0xFF5A5672);
    final Color textColor = const Color(0xFFE1E0F5);

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: textColor,
      minimumSize: const Size(220, 48),
      maximumSize: const Size(250, 48),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor, width: 2),
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
        side: BorderSide(color: borderColor, width: 1),
      ),
      elevation: 4,
    );

    final double topPadding = MediaQuery.of(context).padding.top + 18;

    return Stack(
      fit: StackFit.expand,
      children: [
        const BackgroundWidget(),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                width: 400,
                decoration: BoxDecoration(color: baseColor.withAlpha(191), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SELECT  SAVE  SLOT',
                      textAlign: TextAlign.center,
                      style: TextStyleSingleton().style.copyWith(
                        fontSize: 32,
                        color: textColor,
                        shadows: const [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSlot(slot1, 1, buttonStyle, textColor),
                    const SizedBox(height: 5),
                    _buildSlot(slot2, 2, buttonStyle, textColor),
                    const SizedBox(height: 5),
                    _buildSlot(slot3, 3, buttonStyle, textColor),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        widget.game.overlays.remove(GameSelector.id);
                        widget.game.overlays.add(MainMenu.id);
                      },
                      style: backButtonStyle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back, size: 18),
                          const SizedBox(width: 8),
                          Text('BACK', style: TextStyleSingleton().style.copyWith(fontSize: 13, color: textColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (slotToDelete != null) Center(child: _buildCustomModal(slotToDelete!)),
      ],
    );
  }

  Widget _buildSlot(Game? game, int slotNumber, ButtonStyle style, Color textColor) {
    final isEmpty = game == null;
    final label = isEmpty ? 'Empty' : 'SAVE SLOT $slotNumber - Level ${game.currentLevel + 1}';
    final icon = isEmpty ? Icons.insert_drive_file_outlined : Icons.insert_drive_file;

    return _slotButton(
      label: label,
      icon: icon,
      onPressed: () => _loadSlot(slotNumber, context),
      style: style,
      textColor: textColor,
      isEmpty: isEmpty,
      showDelete: !isEmpty,
      onDelete: () => _confirmDelete(slotNumber),
    );
  }

  Widget _slotButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required ButtonStyle style,
    required Color textColor,
    required bool isEmpty,
    bool showDelete = false,
    VoidCallback? onDelete,
  }) {
    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor.withAlpha(isEmpty ? 102 : 255)),
            ),
          ),
          if (showDelete && onDelete != null) _buildDeleteIcon(onDelete),
        ],
      ),
    );
  }

  Widget _buildDeleteIcon(VoidCallback onDelete) {
    final Color redColor = const Color.fromARGB(255, 199, 89, 89);
    return GestureDetector(
      onTap: onDelete,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(38),
          border: Border.all(color: redColor),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Icon(Icons.delete_outline, color: redColor, size: 18),
      ),
    );
  }

  void _confirmDelete(int slot) {
    setState(() {
      slotToDelete = slot;
    });
  }

  Widget _buildCustomModal(int slot) {
    final Color baseColor = const Color(0xFF212030);
    final Color borderColor = const Color(0xFF5A5672);
    final Color textColor = const Color(0xFFE1E0F5);

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
              Text(
                'DELETE  SLOT  $slot',
                style: TextStyleSingleton().style.copyWith(fontSize: 22, color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              Text(
                'Are  you  sure  you  want  to  delete  this slot?\nThis  action  cannot  be  undone.',
                textAlign: TextAlign.center,
                style: TextStyleSingleton().style.copyWith(fontSize: 14, color: textColor),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => setState(() => slotToDelete = null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: borderColor),
                      ),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: Text('Cancel', style: TextStyleSingleton().style.copyWith(fontSize: 14)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      setState(() => slotToDelete = null);
                      await gameService?.deleteGameBySpace(space: slot);
                      await _loadSlots();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: borderColor),
                      ),
                    ),
                    icon: const Icon(Icons.delete_forever, size: 16),
                    label: Text('Delete', style: TextStyleSingleton().style.copyWith(fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadSlot(int slot, BuildContext context) async {
    widget.game.isOnMenu = false;
    await widget.game.chargeSlot(slot);
    widget.game.overlays.remove(GameSelector.id);
    widget.game.resumeEngine();
  }

  Future<void> getGameService() async {
    gameService ??= await GameService.getInstance();
  }
}
