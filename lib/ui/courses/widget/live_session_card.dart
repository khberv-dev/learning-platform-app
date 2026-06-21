import 'package:flutter/material.dart';
import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';

class LiveSessionCard extends StatelessWidget {
  final LiveLessonEntity lesson;

  const LiveSessionCard({super.key, required this.lesson});

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final months = [
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VideoThumbnail(videoPath: lesson.videoPath),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (lesson.courseTitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        size: 13,
                        color: Color(0xFF18C96A),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lesson.courseTitle,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatDate(lesson.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
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

class _VideoThumbnail extends StatelessWidget {
  final String videoPath;

  const _VideoThumbnail({required this.videoPath});

  @override
  Widget build(BuildContext context) {
    final hasVideo = videoPath.isNotEmpty;

    return SizedBox(
      height: 168,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF111827)),
          if (hasVideo)
            Center(
              child: Container(
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
              ),
            )
          else
            const Center(
              child: Icon(
                Icons.videocam_off_outlined,
                color: Colors.white38,
                size: 36,
              ),
            ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'RECORDED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
