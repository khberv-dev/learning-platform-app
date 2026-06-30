import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';
import 'package:video_player/video_player.dart';

class LiveSessionScreen extends StatefulWidget {
  static const path = '/live-session/:id';

  final LiveLessonEntity session;

  const LiveSessionScreen({super.key, required this.session});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _initializing = false;

  @override
  void initState() {
    super.initState();
    if (widget.session.videoPath.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initPlayer());
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    if (_initializing) return;
    setState(() => _initializing = true);

    final path = widget.session.videoPath;
    final url = path.startsWith('http') ? path : '$hostUrl$path';

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoController = controller;

    await controller.initialize();
    if (!mounted) return;

    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        allowFullScreen: true,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        placeholder: const ColoredBox(color: Color(0xFF0F172A)),
        errorBuilder: (context, msg) => Center(
          child: Text(
            msg,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      );
      _initializing = false;
    });
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(title: session.title),
            _VideoArea(
              chewieController: _chewieController,
              initializing: _initializing,
              hasVideo: session.videoPath.isNotEmpty,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'RECORDED SESSION',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    session.title,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  if (session.mentorName.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: Color(0xFF18C96A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          session.mentorName,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(session.createdAt),
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 18,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoArea extends StatelessWidget {
  final ChewieController? chewieController;
  final bool initializing;
  final bool hasVideo;

  const _VideoArea({
    this.chewieController,
    required this.initializing,
    required this.hasVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      color: const Color(0xFF0F172A),
      child: chewieController != null
          ? Chewie(controller: chewieController!)
          : Center(
              child: initializing
                  ? const CircularProgressIndicator(color: Colors.white54)
                  : hasVideo
                  ? Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    )
                  : const Icon(
                      Icons.videocam_off_outlined,
                      color: Colors.white38,
                      size: 36,
                    ),
            ),
    );
  }
}
