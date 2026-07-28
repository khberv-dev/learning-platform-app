import 'package:flutter/material.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';

/// Pill-shaped progress bar with fully rounded ends on both the track and the
/// fill, animating as [value] changes.
///
/// Material's [LinearProgressIndicator] rounds the track but leaves the fill
/// square at its leading edge, which reads wrong at this thickness.
class AppProgressBar extends StatelessWidget {
  /// Completion in the range 0..1. Values outside are clamped.
  final double value;

  final double height;

  /// Filled portion. Defaults to the theme primary.
  final Color? color;

  final Color trackColor;

  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 14,
    this.color,
    this.trackColor = AppColors.progressTrack,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.round);

    return Semantics(
      value: '${(value.clamp(0.0, 1.0) * 100).round()}%',
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: ColoredBox(
            color: trackColor,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                widthFactor: value.clamp(0.0, 1.0),
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color ?? Theme.of(context).colorScheme.primary,
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
