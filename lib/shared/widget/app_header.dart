import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';

class AppHeader extends StatelessWidget {
  final Widget child;

  const AppHeader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: SizedBox(
        width: double.infinity,
        height: kToolbarHeight,
        child: child,
      ),
    );
  }
}
