import 'package:flutter/material.dart';

enum RoadStepStatus { completed, current, locked }

/// One pillar on the Mission path: green once reached, white with a padlock
/// while still ahead. The current one is green too; the page marks it with a
/// [RoadStepTooltip].
class RoadStepNode extends StatelessWidget {
  final String label;
  final RoadStepStatus status;
  final Size size;

  const RoadStepNode({
    super.key,
    required this.label,
    required this.status,
    required this.size,
  });

  static String imageFor(RoadStepStatus status) =>
      status == RoadStepStatus.locked
      ? 'assets/images/roadmap_step_locked.png'
      : 'assets/images/roadmap_step_done.png';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label, ${status.name}',
      child: Image.asset(
        imageFor(status),
        width: size.width,
        height: size.height,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
  }
}

/// A black speech bubble pointing down at the current pillar.
class RoadStepTooltip extends StatelessWidget {
  static const _ink = Color(0xFF15141A);
  static const arrowHeight = 7.0;

  final String text;

  const RoadStepTooltip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _ink,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(14, arrowHeight),
          painter: _ArrowPainter(),
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = RoadStepTooltip._ink);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => false;
}
