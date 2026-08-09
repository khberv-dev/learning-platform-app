import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/shared/url_launcher.dart';

/// Full-screen reader for an image — pinch to zoom, drag to move, double-tap to
/// zoom straight to the spot you tapped.
///
/// Takes an already-resolved absolute [url]; callers run the CDN path through
/// `resolveMediaUrl` before pushing.
class ImageViewerScreen extends ConsumerStatefulWidget {
  static const path = '/material-image';

  static const double _minScale = 1;
  static const double _maxScale = 5;

  /// Where a double-tap lands when zooming in from the fitted view.
  static const double _doubleTapScale = 2.5;

  final String url;
  final String title;

  const ImageViewerScreen({super.key, required this.url, required this.title});

  @override
  ConsumerState<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends ConsumerState<ImageViewerScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformation = TransformationController();

  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  Animation<Matrix4>? _zoomAnimation;

  /// Where the last double-tap landed, in the viewport's coordinate space.
  Offset _doubleTapPosition = Offset.zero;

  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _transformation.addListener(_onTransformed);
    _animation.addListener(() {
      final value = _zoomAnimation?.value;
      if (value != null) _transformation.value = value;
    });
  }

  @override
  void dispose() {
    _transformation.removeListener(_onTransformed);
    _transformation.dispose();
    _animation.dispose();
    super.dispose();
  }

  void _onTransformed() {
    final scale = _transformation.value.getMaxScaleOnAxis();
    // Only a visible step matters — the controller ticks on every pan frame.
    if ((scale - _scale).abs() > 0.01) setState(() => _scale = scale);
  }

  bool get _isZoomed => _scale > ImageViewerScreen._minScale + 0.01;

  void _animateTo(Matrix4 target) {
    _zoomAnimation = Matrix4Tween(
      begin: _transformation.value,
      end: target,
    ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic));
    _animation.forward(from: 0);
  }

  void _reset() => _animateTo(Matrix4.identity());

  void _handleDoubleTap() {
    if (_isZoomed) {
      _reset();
      return;
    }

    // Scale about the tapped point: translating by -p * (s - 1) keeps whatever
    // sat under the finger pinned there as the image grows.
    const scale = ImageViewerScreen._doubleTapScale;
    _animateTo(
      Matrix4.identity()
        ..translateByDouble(
          -_doubleTapPosition.dx * (scale - 1),
          -_doubleTapPosition.dy * (scale - 1),
          0,
          1,
        )
        ..scaleByDouble(scale, scale, scale, 1),
    );
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.url);
    if (uri != null) await ref.read(urlLauncherProvider).call(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onDoubleTapDown: (details) =>
                  _doubleTapPosition = details.localPosition,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformation,
                minScale: ImageViewerScreen._minScale,
                maxScale: ImageViewerScreen._maxScale,
                // Lets a zoomed image be dragged clear to its corners instead
                // of stopping at the viewport edge.
                boundaryMargin: const EdgeInsets.all(64),
                child: Center(
                  child: Image.network(
                    widget.url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      final expected = progress.expectedTotalBytes;
                      return _Loading(
                        progress: expected != null && expected > 0
                            ? progress.cumulativeBytesLoaded / expected
                            : null,
                      );
                    },
                    errorBuilder: (context, error, stack) =>
                        _LoadFailed(onOpenExternally: _openExternally),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              title: widget.title,
              scale: _scale,
              isZoomed: _isZoomed,
              onReset: _reset,
              onOpenExternally: _openExternally,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String title;
  final double scale;
  final bool isZoomed;
  final VoidCallback onReset;
  final VoidCallback onOpenExternally;

  const _TopBar({
    required this.title,
    required this.scale,
    required this.isZoomed,
    required this.onReset,
    required this.onOpenExternally,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // The image runs under the bar, so it needs its own scrim to stay legible
      // over a light photo.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC000000), Color(0x00000000)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Both the readout and the way back to a fitted view; pointless
              // when the image is already fitted.
              AnimatedOpacity(
                opacity: isZoomed ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: IgnorePointer(
                  ignoring: !isZoomed,
                  child: TextButton.icon(
                    onPressed: onReset,
                    icon: const Icon(
                      Icons.zoom_out_map_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: Text(
                      '${scale.toStringAsFixed(1)}×',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onOpenExternally,
                tooltip: 'Open outside the app',
                icon: const Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── States ────────────────────────────────────────────────────────────────────

class _Loading extends StatelessWidget {
  /// Null until the server reports a content length.
  final double? progress;

  const _Loading({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 3,
          backgroundColor: const Color(0xFF374151),
          valueColor: const AlwaysStoppedAnimation(Color(0xFF18C96A)),
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  final VoidCallback onOpenExternally;

  const _LoadFailed({required this.onOpenExternally});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              color: Color(0xFF9CA3AF),
              size: 36,
            ),
            const SizedBox(height: 12),
            const Text(
              "This image couldn't be loaded",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onOpenExternally,
              child: const Text(
                'Open outside the app',
                style: TextStyle(
                  color: Color(0xFF18C96A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
