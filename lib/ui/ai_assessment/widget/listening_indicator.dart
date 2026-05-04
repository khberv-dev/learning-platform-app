import 'package:flutter/material.dart';

class ListeningIndicator extends StatelessWidget {
  const ListeningIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _Dot(),
        SizedBox(width: 6),
        Text(
          'Listening...',
          style: TextStyle(
            color: Color(0xFF18C96A),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0xFF18C96A),
        shape: BoxShape.circle,
      ),
    );
  }
}
