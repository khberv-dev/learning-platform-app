import 'package:flutter/material.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';

class _Dot extends StatelessWidget {
  final bool isSelected;

  const _Dot({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final double size = 10;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.primary.withAlpha(50);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.round),
        color: color,
      ),
    );
  }
}

class DotProgress extends StatelessWidget {
  final int length;
  final int current;

  const DotProgress({super.key, required this.length, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        length,
        (index) => Row(
          children: [
            _Dot(isSelected: index == current),
            SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}
