
import 'package:flutter/material.dart';

import '../../../style/text_style_singleton.dart';

class MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final ButtonStyle style;
  final VoidCallback onPressed;
  final bool enabled;

  const MenuButton({
    required this.label,
    required this.icon,
    required this.style,
    required this.onPressed,
    required this.enabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: style,
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyleSingleton()
            .style
            .copyWith(fontSize: 14, color: Colors.white),
      ),
    );
  }
}