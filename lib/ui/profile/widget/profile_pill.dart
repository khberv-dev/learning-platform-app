import 'package:flutter/material.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';

/// Outlined pill holding a labelled value — the profile's form rows. Carries
/// the same solid bottom edge as [AppButton.outlined].
class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const ProfileField({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.round),
              border: Border.all(color: AppColors.ink, width: 2),
              boxShadow: const [
                BoxShadow(color: AppColors.ink, offset: Offset(0, 4)),
              ],
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// White pill row inside the dark settings panel.
class ProfileSettingRow extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color labelColor;

  const ProfileSettingRow({
    super.key,
    required this.label,
    this.trailing,
    this.onTap,
    this.labelColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// The muted value plus chevron a settings row shows on its right.
class ProfileSettingValue extends StatelessWidget {
  final String? value;
  final bool showChevron;

  const ProfileSettingValue({super.key, this.value, this.showChevron = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value != null)
          Text(
            value!,
            style: const TextStyle(
              color: Color(0xff6b7a83),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        if (showChevron) ...[
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: Color(0xff6b7a83),
          ),
        ],
      ],
    );
  }
}
