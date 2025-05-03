
import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  final String text;

  const TextDivider({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),
        ),
      ],
    );
  }
}