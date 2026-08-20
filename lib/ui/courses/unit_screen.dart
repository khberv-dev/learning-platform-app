import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';
import 'package:student/core/courses/presentation/course_detail_controller.dart'
    show courseDetailControllerProvider;
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/courses/lesson_screen.dart';

/// Lessons of a single unit. The course page lists units only, so this is the
/// step between it and [LessonScreen].
///
/// Takes the unit's index rather than its id because the whole course detail is
/// already cached by [courseDetailControllerProvider], and [LessonScreen]
/// addresses lessons the same positional way.
class UnitScreen extends ConsumerWidget {
  static const path = '/unit';

  final String courseId;
  final int unitIndex;

  const UnitScreen({
    super.key,
    required this.courseId,
    required this.unitIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseDetailControllerProvider(courseId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ),
          data: (course) {
            if (unitIndex < 0 || unitIndex >= course.units.length) {
              return const _MissingUnit();
            }
            final unit = course.units[unitIndex];
            return Column(
              children: [
                _Header(unitIndex: unitIndex, courseTitle: course.title),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    children: [
                      _UnitSummary(unit: unit),
                      const SizedBox(height: 20),
                      if (unit.lessons.isEmpty)
                        const _NoLessons()
                      else
                        ...List.generate(unit.lessons.length, (i) {
                          return Padding(
                            padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                            child: _LessonCard(
                              lesson: unit.lessons[i],
                              index: i,
                              onTap: () => context.push(
                                '${LessonScreen.path}'
                                '?courseId=$courseId'
                                '&unitIndex=$unitIndex'
                                '&lessonIndex=$i',
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int unitIndex;
  final String courseTitle;

  const _Header({required this.unitIndex, required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).unitNumber((unitIndex + 1).toString().padLeft(2, '0')),
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  courseTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

// ── Unit summary ──────────────────────────────────────────────────────────────

class _UnitSummary extends StatelessWidget {
  final UnitEntity unit;

  const _UnitSummary({required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unit.title,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context).courseLessonCount(unit.lessonsCount),
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
      ],
    );
  }
}

// ── Lesson card ───────────────────────────────────────────────────────────────

class _LessonCard extends StatelessWidget {
  final LessonEntity lesson;
  final int index;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                (index + 1).toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: Color(0xFF18C96A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (lesson.description != null &&
                      lesson.description!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      lesson.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty states ──────────────────────────────────────────────────────────────

class _NoLessons extends StatelessWidget {
  const _NoLessons();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.menu_book_outlined,
            color: Color(0xFF9CA3AF),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).unitNoLessonsTitle,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context).unitNoLessonsSubtitle,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MissingUnit extends StatelessWidget {
  const _MissingUnit();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context).unitNotFound,
        style: const TextStyle(color: Color(0xFF6B7280)),
      ),
    );
  }
}
