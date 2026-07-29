import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  /// Defaults to the dark ink used on light backgrounds; pass white when the
  /// section sits on a dark panel.
  final Color color;

  final double fontSize;

  const SectionTitle({
    super.key,
    required this.title,
    this.color = const Color(0xFF111827),
    this.fontSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }
}
