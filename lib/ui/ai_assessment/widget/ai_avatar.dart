import 'package:flutter/material.dart';

class AiAvatar extends StatelessWidget {
  final double size;
  final double iconSize;

  const AiAvatar({super.key, this.size = 80, this.iconSize = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF18C96A), Color(0xFF059669)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: iconSize),
    );
  }
}
