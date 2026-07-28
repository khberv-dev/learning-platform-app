import 'package:flutter/material.dart';

/// Bare X button for dismissing a flow. Unlike [BackIconButton] it has no
/// filled circle behind it, so it needs an explicit transparent background to
/// opt out of the app-wide `iconButtonTheme`.
class CloseIconButton extends StatelessWidget {
  final VoidCallback? onTap;

  /// Defaults to the theme's `onSurface`.
  final Color? color;

  final double size;

  const CloseIconButton({
    super.key,
    required this.onTap,
    this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
      ),
      icon: Icon(
        Icons.close_rounded,
        size: size,
        weight: 700,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
