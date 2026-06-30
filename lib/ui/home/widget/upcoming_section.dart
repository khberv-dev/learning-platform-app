import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/live_lessons/domain/entity/live_lesson_scheduled_entity.dart';
import 'package:student/core/live_lessons/presentation/live_lessons_controller.dart';
import 'package:student/ui/shared/widget/section_title.dart';
import 'package:url_launcher/url_launcher.dart';

class UpcomingSection extends ConsumerWidget {
  const UpcomingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myLiveLessonsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'More Upcoming Lessons'),
          const SizedBox(height: 12),
          state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const SizedBox.shrink(),
            data: (lessons) {
              final upcoming = lessons
                  .where((l) => l.isUpcoming || l.isOngoing)
                  .skip(1)
                  .take(3)
                  .toList();
              if (upcoming.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  for (int i = 0; i < upcoming.length; i++) ...[
                    _LessonItem(lesson: upcoming[i]),
                    if (i < upcoming.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {
  final LiveLessonScheduledEntity lesson;

  const _LessonItem({required this.lesson});

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
    return '${months[dt.month - 1]} ${dt.day}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<void> _join() async {
    final uri = Uri.tryParse(lesson.meetLink);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = lesson.startTime.toLocal();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(local),
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _formatTime(local),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
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
                if (lesson.teacherName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    lesson.teacherName,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (lesson.meetLink.isNotEmpty) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _join,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(
                    color: Color(0xFF18C96A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
