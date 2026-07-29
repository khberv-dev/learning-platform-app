import 'package:flutter/material.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';

enum _AppButtonVariant { filled, outlined, white }

/// Neutrals for [AppButton.white], matching the greys used elsewhere in the UI.
const _whiteEdge = Color(0xffd1d5db);
const _whiteBorder = Color(0xffe5e7eb);

/// Resolved colours for one variant.
typedef _Style = ({
  Color face,
  Color edge,
  Color foreground,
  Color? border,
  double borderWidth,
  bool hasGloss,
});

/// Chunky pill button with a solid 3D bottom edge. Tapping sinks the face
/// down onto the edge instead of rippling.
///
/// ```dart
/// AppButton.filled(label: "Let's Get a Fresh Start", onTap: _start)
/// AppButton.outlined(label: 'Resume Journey', onTap: _resume)
/// AppButton.white(label: 'Skip', onTap: _skip)
/// ```
///
/// Width is taken from the parent by default, so wrap in a
/// `SizedBox(width: ...)` to constrain it — or pass `shrinkWrap: true` to size
/// it to the label. Pass `onTap: null` to disable.
class AppButton extends StatefulWidget {
  static const double defaultHeight = 56;
  static const double defaultDepth = 6;

  final String label;
  final VoidCallback? onTap;

  /// Fill for [AppButton.filled], border + text for [AppButton.outlined],
  /// face for [AppButton.white]. Defaults to the theme primary, the design's
  /// teal, and the theme surface respectively.
  final Color? color;

  /// Label colour. Defaults to white when filled, [color] when outlined.
  final Color? foregroundColor;

  /// Leading widget, tinted and sized to match the label.
  final Widget? icon;

  /// Label size. Drop this along with [height] for compact, in-card buttons.
  final double fontSize;

  /// Swaps the label for a spinner and blocks taps.
  final bool isLoading;

  /// Height of the face. Total widget height is `height + depth`.
  final double height;

  /// Thickness of the bottom edge, i.e. how far the face travels when pressed.
  final double depth;

  /// Size to the label instead of filling the parent. Use inside a [Row] or
  /// an [Align] for a compact, inline button.
  final bool shrinkWrap;

  final _AppButtonVariant _variant;

  const AppButton.filled({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.foregroundColor,
    this.icon,
    this.fontSize = 17,
    this.isLoading = false,
    this.height = defaultHeight,
    this.depth = defaultDepth,
    this.shrinkWrap = false,
  }) : _variant = _AppButtonVariant.filled;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.foregroundColor,
    this.icon,
    this.fontSize = 17,
    this.isLoading = false,
    this.height = defaultHeight,
    this.depth = defaultDepth,
    this.shrinkWrap = false,
  }) : _variant = _AppButtonVariant.outlined;

  /// Neutral secondary button — white face, dark label, grey edge. Use it for
  /// the lower-priority action sitting under an [AppButton.filled] CTA.
  const AppButton.white({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.foregroundColor,
    this.icon,
    this.fontSize = 17,
    this.isLoading = false,
    this.height = defaultHeight,
    this.depth = defaultDepth,
    this.shrinkWrap = false,
  }) : _variant = _AppButtonVariant.white;

  bool get _isEnabled => onTap != null && !isLoading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  void didUpdateWidget(AppButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget._isEnabled) _isPressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(Theme.of(context).colorScheme);
    final radius = BorderRadius.circular(AppRadius.round);

    return Semantics(
      button: true,
      enabled: widget._isEnabled,
      label: widget.label,
      child: Opacity(
        opacity: widget.onTap == null ? 0.45 : 1,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget._isEnabled ? widget.onTap : null,
          onTapDown: widget._isEnabled ? (_) => _setPressed(true) : null,
          onTapUp: widget._isEnabled ? (_) => _setPressed(false) : null,
          onTapCancel: widget._isEnabled ? () => _setPressed(false) : null,
          child: SizedBox(
            height: widget.height + widget.depth,
            child: Stack(
              // The face is the only non-positioned child, so the fit decides
              // the button's width: expand stretches it to the parent (the
              // default), passthrough lets it shrink to its label.
              fit: widget.shrinkWrap ? StackFit.passthrough : StackFit.expand,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: widget.depth,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: style.edge,
                      borderRadius: radius,
                    ),
                  ),
                ),
                // Sinks by exactly `depth` when pressed, covering the edge.
                AnimatedPadding(
                  duration: const Duration(milliseconds: 70),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                    top: _isPressed ? widget.depth : 0,
                    bottom: _isPressed ? 0 : widget.depth,
                  ),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: style.face,
                        borderRadius: radius,
                        border: style.border == null
                            ? null
                            : Border.all(
                                color: style.border!,
                                width: style.borderWidth,
                              ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (style.hasGloss)
                            const Positioned(
                              left: 16,
                              top: -8,
                              bottom: -8,
                              child: _Gloss(),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: _content(style.foreground),
                          ),
                        ],
                      ),
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

  _Style _resolveStyle(ColorScheme scheme) {
    switch (widget._variant) {
      // Face sits on a darker shade of itself.
      case _AppButtonVariant.filled:
        final base = widget.color ?? scheme.primary;
        return (
          face: base,
          edge: _darken(base, 0.18),
          foreground: widget.foregroundColor ?? scheme.onPrimary,
          border: null,
          borderWidth: 0,
          hasGloss: true,
        );

      // Transparent face; the border colour doubles as the edge.
      case _AppButtonVariant.outlined:
        final base = widget.color ?? AppColors.ink;
        return (
          face: scheme.surface,
          edge: base,
          foreground: widget.foregroundColor ?? base,
          border: base,
          borderWidth: 2.5,
          hasGloss: false,
        );

      // Neutral greys unless a custom face is given, in which case they're
      // derived from it so any tint still reads as the same button.
      case _AppButtonVariant.white:
        final base = widget.color;
        return (
          face: base ?? scheme.surface,
          edge: base == null ? _whiteEdge : _darken(base, 0.14),
          foreground: widget.foregroundColor ?? scheme.onSurface,
          border: base == null ? _whiteBorder : _darken(base, 0.07),
          borderWidth: 1.5,
          hasGloss: false,
        );
    }
  }

  Widget _content(Color foreground) {
    if (widget.isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: foreground),
      );
    }

    final label = Text(
      widget.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: foreground,
        fontSize: widget.fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );

    if (widget.icon == null) return label;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconTheme(
          data: IconThemeData(color: foreground, size: 20),
          child: widget.icon!,
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: label),
      ],
    );
  }
}

/// The pair of slanted highlight stripes near the left edge of a filled button.
class _Gloss extends StatelessWidget {
  const _Gloss();

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withAlpha(70);

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(-0.28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 13, color: color),
          const SizedBox(width: 7),
          Container(width: 7, color: color),
        ],
      ),
    );
  }
}

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
