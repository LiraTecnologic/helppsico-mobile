
import 'package:flutter/material.dart';

class TextLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color textColor;
  final double fontSize;

  const TextLink({
    super.key,
    required this.text,
    required this.onTap,
    this.textColor = const Color(0xFF3B82F6), // Blue color
    this.fontSize = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}