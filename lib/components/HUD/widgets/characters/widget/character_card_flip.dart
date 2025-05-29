import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fruit_collector/components/bbdd/models/character.dart';

class CharacterCardFlip extends StatelessWidget {
  final double angle;
  final bool isFrontVisible;
  final bool isUnlocked;
  final Character character;
  final double size;
  final VoidCallback onTap;

  const CharacterCardFlip({
    super.key,
    required this.angle,
    required this.isFrontVisible,
    required this.isUnlocked,
    required this.character,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(angle),
        child:
            isFrontVisible
                ? _buildFront()
                : Transform(alignment: Alignment.center, transform: Matrix4.rotationY(pi), child: _buildBack()),
      ),
    );
  }

  // Front side of the card
  Widget _buildFront() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3750),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5A5672), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColorFiltered(
              colorFilter:
                  !isUnlocked
                      ? const ColorFilter.matrix(<double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ])
                      : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
              child: Image.asset(
                'assets/images/Main Characters/${character.name}/Jump.png',
                fit: BoxFit.cover,
                width: size * 0.8,
                height: size * 0.8,
              ),
            ),
          ),
          if (!isUnlocked) const Icon(Icons.lock, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  // Back side of the card
  Widget _buildBack() {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3750),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5A5672), width: 2),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            character.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFE1E0F5),
              height: 1.4,
              shadows: [Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 1)],
            ),
          ),
        ),
      ),
    );
  }
}