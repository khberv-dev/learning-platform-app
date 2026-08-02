import 'package:flutter/material.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';

/// Neutral card with artwork, a headline and an explanatory line — the
/// "nothing here yet" placeholder.
class AppEmptyState extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;
  final double imageHeight;

  /// Pass [Colors.transparent] where the placeholder sits directly on the
  /// page rather than in its own card.
  final Color backgroundColor;

  const AppEmptyState({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.imageHeight = 150,
    this.backgroundColor = AppColors.emptySurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
        horizontal: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, height: imageHeight, fit: BoxFit.contain),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff9aa5ad),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
