import 'dart:ui';

/// Where the steps sit on `assets/images/roadmap_background.png`.
///
/// The artwork is 2164x18290 and its path is a serpentine of nineteen straight
/// runs joined by U-turns. These y values are the centres of those runs as a
/// fraction of the artwork's height, traced from the pixels rather than
/// guessed; every run spans x 0.19..0.82.
abstract final class RoadmapPath {
  static const artworkWidth = 2164.0;
  static const artworkHeight = 18290.0;

  static const aspectRatio = artworkHeight / artworkWidth;

  static const runCentresY = <double>[
    0.0426,
    0.0894,
    0.1361,
    0.1831,
    0.2284,
    0.2752,
    0.3225,
    0.3689,
    0.4154,
    0.4621,
    0.5089,
    0.5556,
    0.6024,
    0.6491,
    0.6959,
    0.7426,
    0.7882,
    0.8346,
    0.8811,
  ];

  /// The artwork carries a transparent margin plus a border stroke down its
  /// left edge; without cropping it the page background shows through as a
  /// stripe. Everything is shifted left by this fraction to hide it.
  static const leftCrop = 0.02;

  /// Width the artwork must be drawn at so the crop still reaches the right
  /// edge, as a multiple of the viewport width.
  static const drawWidthFactor = 1 + leftCrop;

  /// Maps an x measured on the raw artwork onto the cropped viewport.
  static double toViewportX(double artworkX) =>
      artworkX * drawWidthFactor - leftCrop;

  /// Two steps per run, inset from the U-turns at either end.
  static const _xNear = 0.34;
  static const _xFar = 0.66;
  static const stepsPerRun = 2;

  static int get capacity => runCentresY.length * stepsPerRun;

  /// Fractional position of step [index], following the path's direction:
  /// the artwork enters top-right, so the first run travels right to left and
  /// each run after it reverses.
  static Offset slot(int index) {
    final run = (index ~/ stepsPerRun).clamp(0, runCentresY.length - 1);
    final withinRun = index % stepsPerRun;
    final travelsLeftToRight = run.isOdd;
    final x = travelsLeftToRight
        ? (withinRun == 0 ? _xNear : _xFar)
        : (withinRun == 0 ? _xFar : _xNear);
    return Offset(toViewportX(x), runCentresY[run]);
  }
}
