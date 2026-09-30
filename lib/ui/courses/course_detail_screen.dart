import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/domain/entity/course_detail_entity.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';
import 'package:student/core/courses/presentation/course_detail_controller.dart'
    show courseDetailControllerProvider, courseUnitsProvider;
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/courses/unit_screen.dart';
import 'package:student/ui/courses/widget/course_detail_sections.dart';
import 'package:student/ui/main/app_screen.dart';
import 'package:student/ui/plans/plans_screen.dart';
import 'package:student/utils/messenger.dart';

/// Tab index of Courses in the navbar, where "See all" leads.
const _coursesTabIndex = 1;

class CourseDetailScreen extends ConsumerWidget {
  static const path = '/course/:id';

  final String courseId;
  final bool isOwned;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.isOwned,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseState = ref.watch(courseDetailControllerProvider(courseId));
    final unitsState = ref.watch(courseUnitsProvider(courseId));

    Widget failed(Object e) => Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          apiErrorMessage(context, e),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF6D737E)),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: courseDetailBackground,
      body: Stack(
        children: [
          courseState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => failed(e),
            data: (course) => unitsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => failed(e),
              data: (units) => _CourseDetailBody(
                course: course,
                units: units,
                isOwned: isOwned,
              ),
            ),
          ),
          // Over the hero, and there through loading and errors too.
          Positioned(
            top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
            left: AppSpacing.md,
            child: const _BackButton(),
          ),
        ],
      ),
    );
  }
}

class _CourseDetailBody extends ConsumerWidget {
  final CourseDetailEntity course;
  final List<UnitEntity> units;
  final bool isOwned;

  const _CourseDetailBody({
    required this.course,
    required this.units,
    required this.isOwned,
  });

  void _openUnit(BuildContext context, int index) =>
      context.push('${UnitScreen.path}?courseId=${course.id}&unitIndex=$index');

  void _openPlans(BuildContext context) =>
      context.push('${PlansScreen.path}?courseId=${course.id}');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final description = course.description;
    final lessons = units.fold(0, (sum, u) => sum + u.lessonsCount);
    final others = <CourseEntity>[
      for (final c
          in ref.watch(availableCoursesControllerProvider).value ?? const [])
        if (c.id != course.id) c,
    ];
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.only(
            // Clear of the buy button when there is one.
            bottom: bottomInset + (isOwned ? AppSpacing.xl : 100),
          ),
          children: [
            CourseHero(
              title: course.title,
              imageUrl: course.image,
              lessonCount: lessons,
              moduleCount: units.length,
              progress: isOwned ? course.totalProgress : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (description != null && description.isNotEmpty) ...[
                    CourseSectionTitle(l10n.courseAbout),
                    const SizedBox(height: AppSpacing.sm),
                    CourseBodyText(description),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  for (final author in course.authors) ...[
                    CourseTeacherCard(author: author),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  CourseSectionTitle(l10n.courseUnits),
                  const SizedBox(height: 10),
                  for (var i = 0; i < units.length; i++) ...[
                    CourseModuleRow(
                      key: ValueKey('module-$i'),
                      unit: units[i],
                      index: i,
                      locked: !isOwned || units[i].isLocked,
                      // A module the student doesn't own leads to buying it;
                      // one still locked in their own course goes nowhere.
                      onTap: !isOwned
                          ? () => _openPlans(context)
                          : units[i].isLocked
                          ? null
                          : () => _openUnit(context, i),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            if (others.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: CourseSectionTitle(
                  l10n.courseOtherCourses,
                  trailing: CourseSeeAllLink(
                    onTap: () {
                      ref.read(navbarControllerProvider.notifier).state =
                          _coursesTabIndex;
                      context.go(AppScreen.path);
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OtherCoursesStrip(
                courses: others,
                onOpen: (c) => context.push('/course/${c.id}?owned=false'),
              ),
            ],
          ],
        ),
        if (!isOwned)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.md,
                bottomInset + AppSpacing.md,
              ),
              // Content scrolls away under a soft fade, not a hard edge.
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    courseDetailBackground.withValues(alpha: 0),
                    courseDetailBackground,
                  ],
                  stops: const [0, 0.45],
                ),
              ),
              child: AppFlatPillButton(
                // A course carries no price of its own — each plan sets one,
                // so this leads to the plan picker rather than to checkout.
                label: l10n.courseChoosePlan,
                background: const Color(0xFF78C93C),
                foreground: Colors.white,
                onTap: () => _openPlans(context),
              ),
            ),
          ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.pop(),
        child: const SizedBox.square(
          dimension: 36,
          child: Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black),
        ),
      ),
    );
  }
}
