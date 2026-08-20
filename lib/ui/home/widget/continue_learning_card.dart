import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/ui/home/widget/home_promo_card.dart';

/// Index of the Courses tab in [AppScreen]'s IndexedStack.
const _coursesTabIndex = 1;

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
          SectionTitle(
            title: AppLocalizations.of(context).homeLibrary,
            color: Colors.white,
            fontSize: 22,
          ),
          const SizedBox(height: AppSpacing.md),
          state.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => const SizedBox.shrink(),
            data: (courses) => courses.isEmpty
                ? const _EmptyState()
                : _CourseList(courses: courses),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return HomePromoCard(
      background: Theme.of(context).colorScheme.surface,
      title: l10n.homeNoCoursesTitle,
      subtitle: l10n.homeNoCoursesSubtitle,
      buttonLabel: l10n.homeNoCoursesButton,
      imagePath: 'assets/images/no_course_puppet.png',
      // Courses is a tab in the shell, not a route, so switch the navbar
      // rather than pushing.
      onTap: () =>
          ref.read(navbarControllerProvider.notifier).state = _coursesTabIndex,
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
                    child: Text(
                      AppLocalizations.of(context).homeResume,
                      style: const TextStyle(
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
                  AppLocalizations.of(context).homeProgress,
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
