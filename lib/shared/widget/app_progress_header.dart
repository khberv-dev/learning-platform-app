import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/shared/widget/app_progress_bar.dart';
import 'package:student/shared/widget/close_icon_button.dart';

/// Top bar for stepped flows — a dismiss button followed by a progress bar
/// that fills the remaining width. Deliberately has no "3/5" counter; the bar
/// carries the progress on its own.
class AppProgressHeader extends StatelessWidget {
  /// Completion in the range 0..1.
  final double progress;

  final VoidCallback onClose;

  /// Tint for the dismiss button. Defaults to the theme's `onSurface`.
  final Color? closeColor;

  const AppProgressHeader({
    super.key,
    required this.progress,
    required this.onClose,
    this.closeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Row(
          children: [
            CloseIconButton(onTap: onClose, color: closeColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: AppProgressBar(value: progress)),
          ],
        ),
      ),
    );
  }
}
