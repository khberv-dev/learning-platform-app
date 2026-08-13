import 'dart:ui';

/// Where the steps sit on `assets/images/roadmap_background.png`.
///
/// The artwork is 2164x18290 and its path is a serpentine of twenty straight
/// runs joined by U-turns. These y values are the centres of those runs as a
/// fraction of the artwork's height, traced from the pixels rather than
/// guessed; every run spans x 0.19..0.82 bar the last, which is the road's
/// stub of a beginning and reaches only x 0.55.
///
/// Listed top-down, the order they were drawn in. Steps run the other way —
/// see [slot].
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
    // The road's blunt beginning, by the shore. It stops at x 0.55 rather than
    // running the full width, which is why it carries a single step.
    0.9274,
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

  /// Where the very first step sits: at the blunt end of the opening stub,
  /// pulled in from the tip so the marker rests on the road.
  static const _xStart = 0.52;

  /// The opening stub is half a run long, so it takes a single step.
  static const stepsOnFirstRun = 1;

  static int get capacity =>
      stepsOnFirstRun + (runCentresY.length - 1) * stepsPerRun;

  /// Fractional position of step [index].
  ///
  /// The ladder starts where the road does — the stub at the foot of the
  /// artwork, by the shore — and climbs from there, so step 0 sits on the
  /// bottom-most run and later steps work upward.
  ///
  /// The serpentine was drawn top-down, entering top-right, which puts each
  /// even run travelling right to left. Walking it in the other direction
  /// flips that, so an even run now travels left to right.
  static Offset slot(int index) {
    // The opening stub holds the single first step, at the road's very start.
    if (index < stepsOnFirstRun) {
      return Offset(toViewportX(_xStart), runCentresY.last);
    }

    final paired = index - stepsOnFirstRun;
    final fromBottom = (1 + paired ~/ stepsPerRun).clamp(
      0,
      runCentresY.length - 1,
    );
    final run = runCentresY.length - 1 - fromBottom;
    final withinRun = paired % stepsPerRun;
    final travelsLeftToRight = run.isEven;
    final x = travelsLeftToRight
        ? (withinRun == 0 ? _xNear : _xFar)
        : (withinRun == 0 ? _xFar : _xNear);
    return Offset(toViewportX(x), runCentresY[run]);
  }
}
