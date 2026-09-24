import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

/// Custom Chewie controls for lesson videos: play/pause, ±15s seek, mute,
/// scrubbing and full screen. While the video plays, the controls fade out
/// after [hideDelay] without interaction; a tap on the video brings them back.
class LessonVideoControls extends StatefulWidget {
  static const seekStep = Duration(seconds: 15);
  static const hideDelay = Duration(seconds: 5);
  static const speeds = [0.5, 1.0, 1.5, 2.0];

  const LessonVideoControls({super.key});

  @override
  State<LessonVideoControls> createState() => _LessonVideoControlsState();
}

class _LessonVideoControlsState extends State<LessonVideoControls> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;
  Timer? _hideTimer;
  bool _visible = true;
  bool _wasPlaying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chewieController = ChewieController.of(context);
    if (_chewieController == chewieController) return;

    _chewieController?.removeListener(_refresh);
    _videoController?.removeListener(_onVideoChanged);
    _chewieController = chewieController;
    _videoController = chewieController.videoPlayerController;
    _chewieController!.addListener(_refresh);
    _videoController!.addListener(_onVideoChanged);

    // A fresh instance is built when entering/leaving full screen, so pick up
    // an already-playing video and start the idle countdown.
    _wasPlaying = _videoController!.value.isPlaying;
    if (_wasPlaying) _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _chewieController?.removeListener(_refresh);
    _videoController?.removeListener(_onVideoChanged);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _onVideoChanged() {
    final isPlaying = _videoController!.value.isPlaying;
    if (isPlaying != _wasPlaying) {
      _wasPlaying = isPlaying;
      if (isPlaying) {
        _scheduleHide();
      } else {
        // Paused or finished: keep the controls on screen.
        _hideTimer?.cancel();
        _visible = true;
      }
    }
    _refresh();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!(_videoController?.value.isPlaying ?? false)) return;
    _hideTimer = Timer(LessonVideoControls.hideDelay, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  void _toggleVisibility() {
    setState(() => _visible = !_visible);
    if (_visible) {
      _scheduleHide();
    } else {
      _hideTimer?.cancel();
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _videoController!;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      if (controller.value.position >= controller.value.duration) {
        await controller.seekTo(Duration.zero);
      }
      await controller.play();
    }
  }

  Future<void> _seekBy(Duration offset) async {
    final value = _videoController!.value;
    var target = value.position + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (target > value.duration) target = value.duration;
    await _videoController!.seekTo(target);
  }

  Future<void> _toggleMute() async {
    final controller = _videoController!;
    await controller.setVolume(controller.value.volume == 0 ? 1 : 0);
  }

  Future<void> _setSpeed(double speed) =>
      _videoController!.setPlaybackSpeed(speed);

  @override
  Widget build(BuildContext context) {
    final video = _videoController;
    final chewie = _chewieController;
    if (video == null || chewie == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final isPlaying = video.value.isPlaying;

    // Any touch while visible restarts the idle countdown; holding a finger
    // down (e.g. while scrubbing) suspends it until release.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (_visible) _hideTimer?.cancel();
      },
      onPointerUp: (_) {
        if (_visible) _scheduleHide();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleVisibility,
        child: AnimatedOpacity(
          key: const ValueKey('lesson-video-controls'),
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: IgnorePointer(
            ignoring: !_visible,
            child: Stack(
              children: [
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _VideoControlButton(
                        icon: const _SeekIcon(forward: false),
                        semanticLabel: l10n.lessonVideoRewind,
                        onPressed: () => _seekBy(-LessonVideoControls.seekStep),
                        size: 44,
                      ),
                      const SizedBox(width: 24),
                      _VideoControlButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 32,
                        ),
                        semanticLabel: isPlaying
                            ? l10n.lessonVideoPause
                            : l10n.lessonVideoPlay,
                        onPressed: _togglePlayback,
                        size: 56,
                      ),
                      const SizedBox(width: 24),
                      _VideoControlButton(
                        icon: const _SeekIcon(forward: true),
                        semanticLabel: l10n.lessonVideoForward,
                        onPressed: () => _seekBy(LessonVideoControls.seekStep),
                        size: 44,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                    child: Row(
                      children: [
                        _VideoControlButton(
                          icon: Icon(
                            video.value.volume == 0
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                          ),
                          semanticLabel: video.value.volume == 0
                              ? l10n.lessonVideoUnmute
                              : l10n.lessonVideoMute,
                          onPressed: _toggleMute,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: VideoProgressIndicator(
                            video,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.white,
                              bufferedColor: Colors.white54,
                              backgroundColor: Colors.black38,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _SpeedButton(
                          currentSpeed: video.value.playbackSpeed,
                          semanticLabel: l10n.lessonVideoSpeed,
                          onSelected: _setSpeed,
                        ),
                        const SizedBox(width: 10),
                        _VideoControlButton(
                          icon: Icon(
                            chewie.isFullScreen
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                          ),
                          semanticLabel: chewie.isFullScreen
                              ? l10n.lessonVideoExitFullscreen
                              : l10n.lessonVideoFullscreen,
                          onPressed: chewie.toggleFullScreen,
                        ),
                      ],
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
}

/// Material has no 15-second replay/forward glyph, so draw the circular arrow
/// with the step count inside it.
class _SeekIcon extends StatelessWidget {
  final bool forward;

  const _SeekIcon({required this.forward});

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color;
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.flip(
          flipX: forward,
          child: const Icon(Icons.replay_rounded, size: 30),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            '${LessonVideoControls.seekStep.inSeconds}',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// Cycles the video between [LessonVideoControls.speeds] via a small popup
/// menu, labelled with the speed currently in effect.
class _SpeedButton extends StatelessWidget {
  final double currentSpeed;
  final String semanticLabel;
  final ValueChanged<double> onSelected;

  const _SpeedButton({
    required this.currentSpeed,
    required this.semanticLabel,
    required this.onSelected,
  });

  static String _label(double speed) =>
      '${speed == speed.roundToDouble() ? speed.toInt() : speed}x';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: PopupMenuButton<double>(
        initialValue: currentSpeed,
        onSelected: onSelected,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (context) => [
          for (final speed in LessonVideoControls.speeds)
            PopupMenuItem(
              value: speed,
              child: Text(
                _label(speed),
                style: TextStyle(
                  color: speed == currentSpeed
                      ? const Color(0xFF18C96A)
                      : const Color(0xFF111827),
                  fontWeight: speed == currentSpeed
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
        ],
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
          ),
          alignment: Alignment.center,
          child: Text(
            _label(currentSpeed),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoControlButton extends StatelessWidget {
  final Widget icon;
  final String semanticLabel;
  final VoidCallback onPressed;
  final double size;

  const _VideoControlButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          iconSize: 22,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          icon: icon,
        ),
      ),
    );
  }
}
