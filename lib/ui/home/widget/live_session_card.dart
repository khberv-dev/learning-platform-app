import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/live_lessons/domain/entity/live_lesson_scheduled_entity.dart';
import 'package:student/core/live_lessons/presentation/live_lessons_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/no_upcoming_lessons_card.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/utils/date_format.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveSessionCard extends ConsumerWidget {
  const LiveSessionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myLiveLessonsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: AppLocalizations.of(context).homeLiveLessons,
            color: Colors.white,
            fontSize: 22,
          ),
          const SizedBox(height: 12),
          state.when(
            loading: () => const _LoadingCard(),
            error: (e, _) => const NoUpcomingLessonsCard(),
            data: (lessons) {
              final next = lessons
                  .where((l) => l.isUpcoming || l.isOngoing)
                  .toList();
              if (next.isEmpty) return const NoUpcomingLessonsCard();
              return _NextLessonCard(lesson: next.first);
            },
          ),
        ],
      ),
    );
  }
}

class _NextLessonCard extends StatelessWidget {
  final LiveLessonScheduledEntity lesson;

  const _NextLessonCard({required this.lesson});

  Future<void> _joinLesson() async {
    final uri = Uri.tryParse(lesson.meetLink);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOngoing = lesson.isOngoing;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOngoing
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOngoing
                            ? const Color(0xFF18C96A)
                            : const Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOngoing
                          ? AppLocalizations.of(context).homeLiveNow
                          : AppLocalizations.of(context).homeUpcoming,
                      style: TextStyle(
                        color: isOngoing
                            ? const Color(0xFF18C96A)
                            : const Color(0xFF3B82F6),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lesson.name,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (lesson.teacherName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 13,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Text(
                  lesson.teacherName,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 13,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 4),
              Text(
                formatMonthDayTime(context, lesson.startTime.toLocal()),
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: Material(
              color: isOngoing
                  ? const Color(0xFF18C96A)
                  : const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                onTap: lesson.meetLink.isNotEmpty ? _joinLesson : null,
                borderRadius: BorderRadius.circular(22),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).homeJoinLesson,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
