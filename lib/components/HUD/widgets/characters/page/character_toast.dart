import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fruit_collector/components/bbdd/models/character.dart';

import '../../../style/text_style_singleton.dart';

class CharacterToast extends StatelessWidget {
  static const String id = 'character_toast';
  final Character character;
  final VoidCallback onDismiss;

  const CharacterToast({
    super.key,
    required this.character,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFF1E1B2E).withOpacity(0.9);
    final Color borderColor = const Color(0xFFF9D342);
    final Color textColor = const Color(0xFFF2F2F2);
    final Color titleColor = const Color(0xFFFFD700);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) => onDismiss(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        offset: const Offset(3, 3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        FontAwesomeIcons.shirt,
                        color: Colors.amber,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Skin desbloqueada',
                            style: TextStyleSingleton().style.copyWith(
                              fontSize: 14,
                              color: titleColor,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            character.name,
                            style: TextStyleSingleton().style.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onDismiss,
                        child: const Icon(Icons.close, size: 20, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}