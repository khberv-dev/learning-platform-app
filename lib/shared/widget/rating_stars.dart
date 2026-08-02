import 'package:flutter/material.dart';
import 'package:student/app/theme/app_colors.dart';

/// Five circular star badges, filled to the nearest whole star.
class RatingStars extends StatelessWidget {
  static const int count = 5;

  final double rating;
  final double size;

  const RatingStars({super.key, required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    // Round to whole badges — these are solid pips, not partially fillable.
    final filled = rating.round().clamp(0, count);

    return Semantics(
      label: '${rating.toStringAsFixed(1)} out of $count',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) SizedBox(width: size * 0.12),
            _Badge(size: size, isFilled: i < filled),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final double size;
  final bool isFilled;

  const _Badge({required this.size, required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? AppColors.ratingFill : AppColors.ratingEmpty,
      ),
      child: Icon(
        Icons.star_rounded,
        size: size * 0.72,
        color: isFilled ? AppColors.ratingInk : AppColors.ratingEmptyInk,
      ),
    );
  }
}
