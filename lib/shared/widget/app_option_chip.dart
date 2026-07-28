import 'package:flutter/material.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';

/// White pill chip with an optional leading glyph, used for survey answers.
///
/// Sizes itself to its content, so lay these out with [Align] or a [Wrap]
/// rather than stretching them to the full width.
class AppOptionChip extends StatelessWidget {
  final String label;

  /// Leading glyph — an emoji [Text] or a small icon. Sized to ~20pt.
  final Widget? leading;

  final bool isSelected;

  /// Lines the label may wrap to before ellipsizing. Keep at 1 for short
  /// survey-style chips; raise it for longer answers.
  final int maxLines;

  final VoidCallback onTap;

  const AppOptionChip({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
    this.isSelected = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadius.round);
    final foreground = isSelected ? scheme.onPrimary : AppColors.ink;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary : scheme.surface,
            borderRadius: radius,
            // Kept transparent when unselected so the chip doesn't change
            // size as it fills in.
            border: Border.all(
              color: isSelected ? scheme.primary : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isSelected ? 38 : 20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // The wrapping Semantics already supplies the label; without this
          // the inner Text (and the emoji) merge in and it gets announced
          // twice.
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  DefaultTextStyle.merge(
                    style: const TextStyle(fontSize: 20),
                    child: IconTheme(
                      data: const IconThemeData(size: 20),
                      child: leading!,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                // Flexible so a long label (or a large text scale) shrinks the
                // chip to the available width instead of overflowing the row.
                Flexible(
                  // Animated so the label fades to white in step with the
                  // container filling in.
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    child: Text(
                      label,
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
