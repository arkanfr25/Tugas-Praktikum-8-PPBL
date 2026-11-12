import 'package:flutter/material.dart';

class ThemeToggleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDark;

  const ThemeToggleButton({
    super.key,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
      ),
      tooltip: 'Ganti Tema',
    );
  }
}