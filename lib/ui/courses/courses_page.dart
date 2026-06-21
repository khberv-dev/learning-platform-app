import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/ui/courses/widget/available_course_card.dart';
import 'package:student/ui/courses/widget/live_session_card.dart';
import 'package:student/ui/courses/widget/my_course_card.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              0,
            ),
            child: Text(
              'Courses',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TabBar(
            tabs: const [
              Tab(text: 'Courses'),
              Tab(text: 'Live Sessions'),
            ],
            labelColor: const Color(0xFF111827),
            unselectedLabelColor: const Color(0xFF9CA3AF),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            indicatorColor: const Color(0xFF18C96A),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: const Color(0xFFE5E7EB),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          ),
          const Expanded(
            child: TabBarView(children: [_CoursesTab(), _LiveSessionsTab()]),
          ),
        ],
      ),
    );
  }
}

class _CoursesTab extends ConsumerWidget {
  const _CoursesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              child: Text(
                'My Courses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                ),
              ),
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
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: _NoMyCoursesCard(),
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                24,
                AppSpacing.xl,
                12,
              ),
              child: Text(
                'Available to Purchase',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                ),
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
                sliver: SliverList.separated(
                  itemCount: courses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      AvailableCourseCard(course: courses[i]),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

class _LiveSessionsTab extends ConsumerWidget {
  const _LiveSessionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveLessonsControllerProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(liveLessonsControllerProvider);
        await ref.read(liveLessonsControllerProvider.future);
      },
      child: state.when(
        loading: () => const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillViewport(
              delegate: SliverChildListDelegate.fixed([
                Center(child: CircularProgressIndicator()),
              ]),
            ),
          ],
        ),
        error: (e, _) => CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillViewport(
              delegate: SliverChildListDelegate.fixed([
                Center(
                  child: Text(
                    e.toString(),
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ]),
            ),
          ],
        ),
        data: (lessons) {
          if (lessons.isEmpty) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillViewport(
                  delegate: SliverChildListDelegate.fixed([
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0FDF4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.videocam_off_outlined,
                            color: Color(0xFF18C96A),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Recorded Sessions',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(
                          width: 260,
                          child: Text(
                            'Recorded live sessions will appear here once available.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ],
            );
          }

          return CustomScrollView(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recorded Sessions',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFF111827),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${lessons.length} sessions',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
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
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NoMyCoursesCard extends StatelessWidget {
  const _NoMyCoursesCard();

  @override
  Widget build(BuildContext context) {
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
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: Color(0xFF18C96A),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }
}
