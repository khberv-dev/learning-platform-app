import 'package:flutter/material.dart';
import 'package:student/utils/lib.dart';

/// Gradients for course covers, cycled by position: green, blue, orange,
/// purple — the order the mockups list them in.
const courseCoverGradients = <List<Color>>[
  [Color(0xFF9BD861), Color(0xFF78C93C)],
  [Color(0xFF7AC5F4), Color(0xFF4FA8EE)],
  [Color(0xFFFFC56B), Color(0xFFF59E2B)],
  [Color(0xFFD9A6FA), Color(0xFFB57CF2)],
];

/// A course's cover: its banner image when it has one, otherwise a coloured
/// gradient with a soft, oversized chevron watermark and the course title
/// centred in white. The gradient also stands in while the image loads and
/// if it fails (e.g. an expired signed URL).
class CourseCoverTile extends StatelessWidget {
  final String title;

  /// The course's banner. Null or empty falls back to the gradient.
  final String? imageUrl;

  /// Which of [courseCoverGradients] to use; wraps around.
  final int colorIndex;

  final double height;
  final double titleSize;

  const CourseCoverTile({
    super.key,
    required this.title,
    required this.colorIndex,
    this.imageUrl,
    this.height = 138,
    this.titleSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    final url = resolveMediaUrl(imageUrl);
    if (url == null) return _gradient();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.network(
          url,
          key: const ValueKey('course-cover-image'),
          fit: BoxFit.cover,
          // The gradient shows until the image arrives, and stays if it
          // never does.
          frameBuilder: (_, child, frame, wasSynchronouslyLoaded) =>
              frame == null && !wasSynchronouslyLoaded ? _gradient() : child,
          errorBuilder: (_, _, _) => _gradient(),
        ),
      ),
    );
  }

  Widget _gradient() {
    final colors =
        courseCoverGradients[colorIndex % courseCoverGradients.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The mockups' faint glassy shapes behind the title.
              Positioned(
                left: -height * 0.35,
                top: -height * 0.3,
                child: _Watermark(size: height * 1.1),
              ),
              Positioned(
                right: -height * 0.45,
                bottom: -height * 0.55,
                child: _Watermark(size: height * 1.2),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Watermark extends StatelessWidget {
  final double size;

  const _Watermark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.6,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(size * 0.22),
        ),
      ),
    );
  }
}
