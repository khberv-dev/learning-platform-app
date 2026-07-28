import 'package:flutter/material.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';

/// White card pinned to the bottom of a screen, holding the primary and
/// secondary actions. Rounded on its top corners only, and its own [SafeArea]
/// keeps the white running under the home indicator instead of leaving a
/// strip of whatever is behind it.
///
/// Children are stacked with [AppSpacing.md] between them; pass [AppButton]s.
class AppBottomActionBar extends StatelessWidget {
  final List<Widget> children;

  const AppBottomActionBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
