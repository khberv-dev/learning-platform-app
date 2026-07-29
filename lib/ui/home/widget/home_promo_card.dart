import 'package:flutter/material.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/shared/widget/app_button.dart';

/// A home-page promo tile: heading, supporting copy and a compact action on
/// the left, artwork bleeding off the right edge.
class HomePromoCard extends StatelessWidget {
  final Color background;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;
  final String imagePath;

  /// Defaults to near-black on a light card and white on a dark one.
  final Color? foreground;

  /// Fill for the action. Defaults to the theme primary.
  final Color? buttonColor;

  final double imageWidth;

  const HomePromoCard({
    super.key,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
    required this.imagePath,
    this.foreground,
    this.buttonColor,
    this.imageWidth = 128,
  });

  @override
  Widget build(BuildContext context) {
    final ink =
        foreground ??
        (ThemeData.estimateBrightnessForColor(background) == Brightness.dark
            ? Colors.white
            : Colors.black);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: ColoredBox(
        color: background,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: ink.withAlpha(150),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton.filled(
                      label: buttonLabel,
                      onTap: onTap,
                      color: buttonColor,
                      shrinkWrap: true,
                      height: 44,
                      depth: 5,
                      fontSize: 15,
                    ),
                  ],
                ),
              ),
            ),
            Image.asset(imagePath, width: imageWidth, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
