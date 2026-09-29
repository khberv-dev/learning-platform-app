import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AppMessageType { success, error }

/// The redesign's message pill: a pale tinted stadium with a white badge on
/// the left, a coloured bold [title] and an optional grey [detail] line.
///
/// Shown as a floating SnackBar through `lib/utils/messenger.dart`; build it
/// directly only where a message has to sit inline.
class AppFloatingMessage extends StatelessWidget {
  final AppMessageType type;
  final String title;
  final String? detail;

  const AppFloatingMessage({
    super.key,
    required this.type,
    required this.title,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[type]!;
    final detail = this.detail;

    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.fromLTRB(10, 10, 24, 10),
      decoration: BoxDecoration(
        color: palette.fill,
        borderRadius: BorderRadius.circular(34),
        // The mockup's edge is soft, not a hard line.
        boxShadow: [BoxShadow(color: palette.fill, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: type == AppMessageType.error
                ? const _ErrorBadge()
                : const _SuccessBadge(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.title,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                if (detail != null && detail.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: Color(0xFF717384),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

typedef _Palette = ({Color fill, Color title});

const _palettes = <AppMessageType, _Palette>{
  AppMessageType.success: (fill: Color(0xFFF0FAE8), title: Color(0xFF78C93C)),
  AppMessageType.error: (fill: Color(0xFFFCEEED), title: Color(0xFFEC5A53)),
};

/// A green disc with a white tick.
class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8CD24D), Color(0xFF78C93C)],
        ),
      ),
      child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
    );
  }
}

/// A red, round-cornered, point-up hexagon with a white "!".
class _ErrorBadge extends StatelessWidget {
  const _ErrorBadge();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(21, 24),
      painter: const _HexagonPainter(),
      child: const SizedBox(
        width: 21,
        height: 24,
        child: Icon(Icons.priority_high_rounded, size: 14, color: Colors.white),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  const _HexagonPainter();

  static const _cornerRadius = 3.5;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final r = size.height / 2;
    final vertices = [
      for (var i = 0; i < 6; i++)
        centre + Offset.fromDirection(-math.pi / 2 + i * math.pi / 3, r),
    ];

    // Each corner is cut [_cornerRadius] back along both edges and joined
    // with a curve through the original vertex.
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final prev = vertices[(i + 5) % 6];
      final curr = vertices[i];
      final next = vertices[(i + 1) % 6];
      final entry = curr + _towards(curr, prev, _cornerRadius);
      final exit = curr + _towards(curr, next, _cornerRadius);
      if (i == 0) {
        path.moveTo(entry.dx, entry.dy);
      } else {
        path.lineTo(entry.dx, entry.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, exit.dx, exit.dy);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF07F7A), Color(0xFFEC625D)],
        ).createShader(Offset.zero & size),
    );
  }

  Offset _towards(Offset from, Offset to, double distance) {
    final d = to - from;
    return d / d.distance * distance;
  }

  @override
  bool shouldRepaint(_HexagonPainter oldDelegate) => false;
}
