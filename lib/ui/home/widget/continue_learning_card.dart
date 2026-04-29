import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/ui/shared/widget/section_title.dart';

class ContinueLearningCard extends ConsumerWidget {
  const ContinueLearningCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myCoursesControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Continue Learning'),
          const SizedBox(height: 10),
          state.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => const SizedBox.shrink(),
            data: (courses) =>
                courses.isEmpty ? _EmptyState() : _CourseList(courses: courses),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF18C96A),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No active courses yet',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Browse and start learning today',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Course list ───────────────────────────────────────────────────────────────

class _CourseList extends StatelessWidget {
  final List<MyCourseEntity> courses;

  const _CourseList({required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.length == 1) {
      return _CourseCard(course: courses.first, fullWidth: true);
    }
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: courses.length,
        separatorBuilder: (context, i) => const SizedBox(width: 12),
        itemBuilder: (_, i) =>
            _CourseCard(course: courses[i], fullWidth: false),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final MyCourseEntity course;
  final bool fullWidth;

  const _CourseCard({required this.course, required this.fullWidth});

  @override
  Widget build(BuildContext context) {
    final percent = (course.progress * 100).round();
    final expired = course.status == CourseStatus.expired;

    return GestureDetector(
      onTap: () => context.push('/course/${course.courseId}?owned=true'),
      child: Container(
        width: fullWidth ? double.infinity : 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: expired
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B7280), Color(0xFF374151)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF18C96A), Color(0xFF059669)],
                ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                if (!expired)
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Resume',
                      style: TextStyle(
                        color: Color(0xFF18C96A),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    color: expired ? Colors.white54 : const Color(0xFFD1FAE5),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: course.progress.clamp(0.0, 1.0),
                color: Colors.white,
                backgroundColor: expired
                    ? Colors.white24
                    : const Color(0xFF14A558),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
