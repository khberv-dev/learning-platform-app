import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The profile's crown and locale icons, from `assets/icons`.
///
/// Both artworks are drawn in the brand blue. Pass a [color] to tint the
/// whole glyph — e.g. white on a blue badge — or leave it null for the
/// original colours.
abstract final class ProfileIcons {
  static Widget crown({required double size, Color? color}) =>
      _svg('assets/icons/crown.svg', size, color);

  static Widget locale({required double size, Color? color}) =>
      _svg('assets/icons/locale.svg', size, color);

  static Widget _svg(String asset, double size, Color? color) =>
      SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color, BlendMode.srcIn),
      );
}
