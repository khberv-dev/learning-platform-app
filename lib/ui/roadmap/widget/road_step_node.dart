import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';

enum RoadStepStatus { completed, current, locked }

/// A marker sitting on the roadmap path, with its label beneath.
class RoadStepNode extends StatelessWidget {
  static const double diameter = 52;

  final String label;
  final RoadStepStatus status;
  final VoidCallback? onTap;

  const RoadStepNode({
    super.key,
    required this.label,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '$label, ${status.name}',
      child: GestureDetector(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(dimension: diameter, child: _badge()),
              const SizedBox(height: AppSpacing.xs),
              _Label(text: label, isMuted: status == RoadStepStatus.locked),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge() {
    // Only complete and current artwork ships; locked reuses the completed
    // badge drained of colour so it still reads as the same object.
    final image = Image.asset(
      status == RoadStepStatus.current
          ? 'assets/images/road_item_current.png'
          : 'assets/images/road_item_complete.png',
      fit: BoxFit.contain,
    );

    if (status != RoadStepStatus.locked) return image;

    return Opacity(
      opacity: 0.55,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0, 0, 0, 1, 0, //
        ]),
        child: image,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool isMuted;

  const _Label({required this.text, required this.isMuted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        // A chip rather than bare text — the field behind varies in tone and
        // has trees and bushes running through it.
        color: Colors.white.withAlpha(isMuted ? 150 : 225),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isMuted ? const Color(0xff6b7a83) : const Color(0xff1f4e5f),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}
