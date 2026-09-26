import 'package:flutter/material.dart';
import 'package:student/app/theme/app_radius.dart';

/// The redesign's button: a flat pill with a soft drop shadow, no gloss or
/// 3D press-sink like the older `AppButton`. `onTap: null` disables it and
/// swaps in a pale tint of [background]/[foreground] instead of dimming with
/// opacity, matching the mockups' washed-out disabled look.
class AppFlatPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;

  /// Shown before the label when set, tinted to match [foreground].
  final Widget? icon;

  const AppFlatPillButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.background,
    required this.foreground,
    this.icon,
  });

  bool get _enabled => onTap != null;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.round);
    final face = _enabled
        ? background
        : Color.lerp(background, Colors.white, 0.65)!;
    final ink = _enabled ? foreground : foreground.withValues(alpha: 0.75);

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _enabled ? 0.12 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: face,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      IconTheme.merge(
                        data: IconThemeData(color: ink, size: 18),
                        child: icon!,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
