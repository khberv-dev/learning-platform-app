import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/core/live_lessons/presentation/live_lessons_controller.dart';
import 'package:student/shared/widget/app_empty_state.dart';
import 'package:student/shared/widget/no_upcoming_lessons_card.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/ui/courses/widget/available_course_card.dart';
import 'package:student/ui/courses/widget/courses_tab_bar.dart';
import 'package:student/ui/courses/widget/live_lesson_card.dart';
import 'package:student/ui/courses/widget/live_session_card.dart';
import 'package:student/ui/courses/widget/my_course_card.dart';
import 'package:student/ui/home/widget/home_promo_card.dart';
import 'package:student/ui/roadmap/roadmap_screen.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg + MediaQuery.paddingOf(context).top,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: const SectionTitle(title: 'Courses', fontSize: 30),
        ),
        CoursesTabBar(
          labels: const ['Courses', 'Live sessions'],
          current: _tab,
          onSelected: (i) => setState(() => _tab = i),
          // Roadmap is its own screen, not a tab, so it never reads as active.
          actionLabel: 'Roadmap',
          onAction: () => context.push(RoadmapScreen.path),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: IndexedStack(
            index: _tab,
            children: const [_CoursesTab(), _LiveSessionsTab()],
          ),
        ),
      ],
    );
  }
}

class _CoursesTab extends ConsumerStatefulWidget {
  const _CoursesTab();

  @override
  ConsumerState<_CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends ConsumerState<_CoursesTab> {
  /// Anchors the "Available to purchase" heading so the empty state's button
  /// can scroll straight to it.
  final _availableKey = GlobalKey();

  void _scrollToAvailable() {
    final target = _availableKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final myCourses = ref.watch(myCoursesControllerProvider);
    final available = ref.watch(availableCoursesControllerProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myCoursesControllerProvider);
        ref.invalidate(availableCoursesControllerProvider);
        await Future.wait([
          ref.read(myCoursesControllerProvider.future),
          ref.read(availableCoursesControllerProvider.future),
        ]);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                20,
                AppSpacing.xl,
                12,
              ),
              child: const SectionTitle(title: 'My courses', fontSize: 22),
            ),
          ),
          myCourses.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  e.toString(),
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            ),
            data: (courses) {
              if (courses.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: _NoMyCourses(onBrowse: _scrollToAvailable),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverList.separated(
                  itemCount: courses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => MyCourseCard(course: courses[i]),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              key: _availableKey,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                24,
                AppSpacing.xl,
                12,
              ),
              child: const SectionTitle(
                title: 'Available to purchase',
                fontSize: 22,
              ),
            ),
          ),
          available.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  e.toString(),
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            ),
            data: (courses) {
              if (courses.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Text(
                      'No courses available.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverGrid.builder(
                  itemCount: courses.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (_, i) =>
                      AvailableCourseCard(course: courses[i]),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveSessionsTab extends ConsumerWidget {
  const _LiveSessionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordedState = ref.watch(liveLessonsControllerProvider);
    final scheduledState = ref.watch(myLiveLessonsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(liveLessonsControllerProvider);
        ref.invalidate(myLiveLessonsProvider);
        await Future.wait([
          ref.read(liveLessonsControllerProvider.future),
          ref.read(myLiveLessonsProvider.future),
        ]);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Current & Upcoming section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                20,
                AppSpacing.xl,
                12,
              ),
              child: const SectionTitle(
                title: 'Current & Upcoming',
                fontSize: 22,
              ),
            ),
          ),
          scheduledState.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, st) =>
                const SliverToBoxAdapter(child: _NoUpcomingSessions()),
            data: (lessons) {
              final upcoming = lessons
                  .where((l) => l.isUpcoming || l.isOngoing)
                  .toList();
              if (upcoming.isEmpty) {
                return const SliverToBoxAdapter(child: _NoUpcomingSessions());
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverList.separated(
                  itemCount: upcoming.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => LiveLessonCard(lesson: upcoming[i]),
                ),
              );
            },
          ),
          // Past / Recorded section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                24,
                AppSpacing.xl,
                12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(title: 'Past sessions', fontSize: 22),
                  // Only meaningful once something has been recorded.
                  if ((recordedState.value?.length ?? 0) > 0)
                    Text(
                      '${recordedState.value!.length} recorded',
                      style: const TextStyle(
                        color: Color(0xff9aa5ad),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          recordedState.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, st) =>
                const SliverToBoxAdapter(child: _NoRecordedSessions()),
            data: (lessons) {
              if (lessons.isEmpty) {
                return const SliverToBoxAdapter(child: _NoRecordedSessions());
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  96,
                ),
                sliver: SliverList.separated(
                  itemCount: lessons.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => LiveSessionCard(lesson: lessons[i]),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoUpcomingSessions extends StatelessWidget {
  const _NoUpcomingSessions();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: NoUpcomingLessonsCard(),
    );
  }
}

class _NoRecordedSessions extends StatelessWidget {
  const _NoRecordedSessions();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: AppEmptyState(
        imagePath: 'assets/images/no_recorded_sessions_puppet.png',
        title: 'No recorded sessions',
        subtitle: 'Recorded live sessions will appear\nhere once available',
      ),
    );
  }
}

class _NoMyCourses extends StatelessWidget {
  final VoidCallback onBrowse;

  const _NoMyCourses({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return HomePromoCard(
      background: Theme.of(context).colorScheme.surface,
      title: 'No active courses yet',
      subtitle: 'Browse and start learning today',
      buttonLabel: 'Start practice',
      imagePath: 'assets/images/no_course_puppet.png',
      // Already on the courses tab, so browsing means the list below.
      onTap: onBrowse,
    );
  }
}
