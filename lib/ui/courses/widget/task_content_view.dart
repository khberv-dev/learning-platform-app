import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/courses/domain/entity/task_content_type.dart';
import 'package:student/ui/courses/image_viewer_screen.dart';
import 'package:student/utils/lib.dart';

/// The material a task hangs its questions on — an audio clip, a picture, or a
/// text passage.
///
/// [file] is a CDN path for [TaskContentType.audio] and
/// [TaskContentType.picture], but the passage itself for
/// [TaskContentType.text].
class TaskContentView extends StatelessWidget {
  final String file;
  final TaskContentType contentType;

  /// Names the picture in the full-screen viewer — pass the task's name.
  final String title;

  const TaskContentView({
    super.key,
    required this.file,
    required this.contentType,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return switch (contentType) {
      TaskContentType.audio => _AudioContent(url: resolveMediaUrl(file)!),
      TaskContentType.picture => _PictureContent(
        url: resolveMediaUrl(file)!,
        title: title,
      ),
      TaskContentType.text => _TextContent(text: file),
    };
  }
}

// ── Audio ─────────────────────────────────────────────────────────────────────

class _AudioContent extends StatefulWidget {
  final String url;

  const _AudioContent({required this.url});

  @override
  State<_AudioContent> createState() => _AudioContentState();
}

class _AudioContentState extends State<_AudioContent> {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll([
      _player.onDurationChanged.listen((d) {
        if (mounted) setState(() => _duration = d);
      }),
      _player.onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      }),
      _player.onPlayerStateChanged.listen((s) {
        if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
      }),
      // Rewind on completion so the clip can be replayed from the top.
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _position = Duration.zero);
      }),
    ]);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play(UrlSource(widget.url));
      }
    } catch (_) {
      if (mounted) setState(() => _hasFailed = true);
    }
  }

  Future<void> _seek(double seconds) async {
    await _player.seek(Duration(milliseconds: (seconds * 1000).round()));
  }

  static String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasFailed) {
      return const _ContentError(message: 'Audio could not be played');
    }

    final total = _duration.inMilliseconds / 1000;
    final current = _position.inMilliseconds / 1000;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF18C96A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: const Color(0xFF18C96A),
                    inactiveTrackColor: const Color(0xFFE5E7EB),
                    thumbColor: const Color(0xFF18C96A),
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    // The duration only arrives once playback starts, so keep
                    // the slider inert (max 1) until then.
                    value: total > 0 ? current.clamp(0, total) : 0,
                    max: total > 0 ? total : 1,
                    onChanged: total > 0 ? _seek : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _format(_position),
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _format(_duration),
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Picture ───────────────────────────────────────────────────────────────────

class _PictureContent extends StatelessWidget {
  final String url;
  final String title;

  const _PictureContent({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : Container(
                    height: 180,
                    color: const Color(0xFFF3F4F6),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
            errorBuilder: (context, error, stack) =>
                const _ContentError(message: 'Image could not be loaded'),
          ),
        ),
        // Detail in a task picture is often the whole question, and the card is
        // too narrow to read it in — so the full-screen viewer is a tap away.
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push(
                '${ImageViewerScreen.path}'
                '?url=${Uri.encodeQueryComponent(url)}'
                '&title=${Uri.encodeQueryComponent(title)}',
              ),
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.zoom_out_map_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Text ──────────────────────────────────────────────────────────────────────

class _TextContent extends StatelessWidget {
  final String text;

  const _TextContent({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 14,
          height: 1.7,
        ),
      ),
    );
  }
}

// ── Shared failure state ──────────────────────────────────────────────────────

class _ContentError extends StatelessWidget {
  final String message;

  const _ContentError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFF9CA3AF),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
