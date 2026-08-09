import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:student/shared/url_launcher.dart';

/// In-app reader for a PDF material.
///
/// [PdfViewer.uri] streams the document itself, so there is no download step to
/// manage here — the files sit on the public CDN and need no auth header.
class PdfViewerScreen extends ConsumerStatefulWidget {
  static const path = '/material-pdf';

  final String url;
  final String title;

  const PdfViewerScreen({super.key, required this.url, required this.title});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  final PdfViewerController _controller = PdfViewerController();

  int? _pageCount;
  int _currentPage = 1;

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.url);
    if (uri != null) await ref.read(urlLauncherProvider).call(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: widget.title,
              // The page counter only firms up once the document reports its
              // length, so it stays hidden until then.
              subtitle: _pageCount == null
                  ? null
                  : 'Page $_currentPage of $_pageCount',
              onOpenExternally: _openExternally,
            ),
            Expanded(
              child: PdfViewer.uri(
                Uri.parse(widget.url),
                controller: _controller,
                params: PdfViewerParams(
                  backgroundColor: const Color(0xFF1F2937),
                  margin: 8,
                  // Fires while the viewer is laying out, so the page count
                  // lands on the next frame rather than mid-build.
                  onViewerReady: (document, controller) {
                    final count = document.pages.length;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _pageCount != count) {
                        setState(() => _pageCount = count);
                      }
                    });
                  },
                  onPageChanged: (pageNumber) {
                    if (pageNumber != null) {
                      setState(() => _currentPage = pageNumber);
                    }
                  },
                  loadingBannerBuilder:
                      (context, bytesDownloaded, totalBytes) => _LoadingBanner(
                        bytesDownloaded: bytesDownloaded,
                        totalBytes: totalBytes,
                      ),
                  errorBannerBuilder: (context, error, stack, documentRef) =>
                      _ErrorBanner(onOpenExternally: _openExternally),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onOpenExternally;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onOpenExternally,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            // An escape hatch to the system viewer, which is also the only way
            // to print or share the file.
            onPressed: onOpenExternally,
            tooltip: 'Open outside the app',
            icon: const Icon(
              Icons.open_in_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banners ───────────────────────────────────────────────────────────────────

class _LoadingBanner extends StatelessWidget {
  final int bytesDownloaded;
  final int? totalBytes;

  const _LoadingBanner({
    required this.bytesDownloaded,
    required this.totalBytes,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalBytes;
    final progress = total != null && total > 0
        ? (bytesDownloaded / total).clamp(0.0, 1.0)
        : null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              // Indeterminate until the server reports a content length.
              value: progress,
              strokeWidth: 3,
              backgroundColor: const Color(0xFF374151),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF18C96A)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            progress == null ? 'Loading…' : '${(progress * 100).round()}%',
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final VoidCallback onOpenExternally;

  const _ErrorBanner({required this.onOpenExternally});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFF9CA3AF),
              size: 36,
            ),
            const SizedBox(height: 12),
            const Text(
              "This PDF couldn't be opened",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'It may be damaged, or the connection dropped.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
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
