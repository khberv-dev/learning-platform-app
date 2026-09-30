import 'dart:ui';

/// Where the pillars sit on the Mission path, as fractions of the page width
/// (measured off the mockup).
///
/// Steps climb from the bottom in a zigzag across four columns —
/// 0, 1, 2, 3, 2, 1, 0, 1, … — each one a row higher than the last.
abstract final class RoadmapLayout {
  /// Centre of each column.
  static const columnCentres = <double>[0.186, 0.391, 0.595, 0.792];

  /// The column walk, repeated for as many steps as there are.
  static const _walk = <int>[0, 1, 2, 3, 2, 1];

  /// A pillar image's width. The artwork has side margins, so the visible
  /// pillar is narrower than this.
  static const pillarWidth = 0.217;

  /// Height over width of the pillar artwork (366x512).
  static const pillarAspect = 512 / 366;

  /// Rise from one step to the next.
  static const rowHeight = 0.111;

  /// Where the pillar's top face starts, as a fraction of the image height.
  static const capTop = 0.09;

  static int column(int index) => _walk[index % _walk.length];

  /// Size of one pillar image on a page [width] wide.
  static Size pillarSize(double width) {
    final w = width * pillarWidth;
    return Size(w, w * pillarAspect);
  }

  /// Height of a path of [count] steps, from the top of the highest pillar
  /// to the bottom of the lowest.
  static double pathHeight(int count, double width) =>
      (count - 1) * width * rowHeight + pillarSize(width).height;

  /// Top-left of step [index]'s image, in a path [pathHeight] tall.
  static Offset pillarOrigin(int index, int count, double width) {
    final size = pillarSize(width);
    final x = columnCentres[column(index)] * width - size.width / 2;
    final y =
        pathHeight(count, width) - size.height - index * width * rowHeight;
    return Offset(x, y);
  }
}
