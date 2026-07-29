import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/shared/widget/app_panel.dart';

/// One of the three blue tiles under the streak card: artwork, a value, and
/// a caption.
class StatChip extends StatelessWidget {
  final String imagePath;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const StatChip({
    super.key,
    required this.imagePath,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, height: 42),
          const SizedBox(height: AppSpacing.md),
          // Values run to five digits and "Global ranking" is wider than a
          // third of the screen, so both scale down rather than wrap.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xff8fa3b0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
