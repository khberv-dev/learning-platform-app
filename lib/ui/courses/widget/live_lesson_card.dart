import 'package:flutter/material.dart';
import 'package:student/core/live_lessons/domain/entity/live_lesson_scheduled_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveLessonCard extends StatelessWidget {
  final LiveLessonScheduledEntity lesson;

  const LiveLessonCard({super.key, required this.lesson});

  String _formatDate(DateTime dt) {
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
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day} · $hour:$minute $period';
  }

  Future<void> _join() async {
    final uri = Uri.tryParse(lesson.meetLink);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOngoing = lesson.isOngoing;
    final local = lesson.startTime.toLocal();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isOngoing
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFF0F9FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOngoing ? Icons.videocam_rounded : Icons.schedule_outlined,
              size: 20,
              color: isOngoing
                  ? const Color(0xFF18C96A)
                  : const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.name,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(local),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
                if (lesson.teacherName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    lesson.teacherName,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: lesson.meetLink.isNotEmpty ? _join : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isOngoing
                    ? const Color(0xFF18C96A)
                    : const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOngoing ? 'Join' : 'Join',
                style: TextStyle(
                  color: isOngoing ? Colors.white : const Color(0xFF3B82F6),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
