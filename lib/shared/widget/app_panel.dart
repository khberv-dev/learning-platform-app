import 'package:flutter/material.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';

/// Pale blue card with a solid outline — the home page's stat surface.
class AppPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color = AppColors.panelFill,
    this.borderColor = AppColors.panelBorder,
    this.borderWidth = 3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: child,
    );

    if (onTap == null) return panel;
    return GestureDetector(onTap: onTap, child: panel);
  }
}
