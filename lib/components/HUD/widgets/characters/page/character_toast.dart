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
    final Color backgroundColor = const Color(0xFF1E1B2E).withAlpha(230);
    final Color borderColor = const Color(0xFFF9D342);
    final Color textColor = const Color(0xFFF2F2F2);
    final Color titleColor = const Color(0xFFFFD700);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) => onDismiss(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(102),
                        offset: const Offset(2, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          FontAwesomeIcons.shirt,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Character Unlocked',
                            style: TextStyleSingleton().style.copyWith(
                              fontSize: 12,
                              color: titleColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            character.name,
                            style: TextStyleSingleton().style.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onDismiss,
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white70,
                        ),
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