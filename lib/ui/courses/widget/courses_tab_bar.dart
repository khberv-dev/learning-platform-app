import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/shared/widget/app_button.dart';

/// Pill tab strip. The active tab is the outlined pill and the rest are
/// filled — the inverse of the usual emphasis, matching the design.
///
/// Scrolls horizontally so the labels never overflow on narrow screens.
class CoursesTabBar extends StatelessWidget {
  final List<String> labels;
  final int current;
  final ValueChanged<int> onSelected;

  /// Trailing pill that navigates away instead of selecting a tab.
  final String? actionLabel;
  final VoidCallback? onAction;

  const CoursesTabBar({
    super.key,
    required this.labels,
    required this.current,
    required this.onSelected,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            _Pill(
              label: labels[i],
              isActive: i == current,
              onTap: () => onSelected(i),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(width: AppSpacing.sm),
            _Pill(label: actionLabel!, isActive: false, onTap: onAction),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _Pill({required this.label, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return AppButton.outlined(
        label: label,
        onTap: onTap,
        shrinkWrap: true,
        height: 42,
        depth: 4,
        fontSize: 15,
      );
    }
    return AppButton.filled(
      label: label,
      onTap: onTap,
      shrinkWrap: true,
      height: 42,
      depth: 4,
      fontSize: 15,
    );
  }
}
