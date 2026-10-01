import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/course_tiles.dart';
import 'package:student/ui/courses/widget/courses_page_cards.dart';
import 'package:student/utils/messenger.dart';

/// How many of each list show before "See all".
const _myCoursesPreview = 1;
const _availablePreview = 4;

/// The navbar's Courses tab: a search box, the student's current courses,
/// and a grid of courses on sale. Each list shows a preview until "See all"
/// opens it up; a search always shows every match.
class CoursesPage extends ConsumerStatefulWidget {
  const CoursesPage({super.key});

  @override
  ConsumerState<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends ConsumerState<CoursesPage> {
  final _search = TextEditingController();

  bool _showAllMine = false;
  bool _showAllAvailable = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String get _query => _search.text.trim().toLowerCase();

  bool _matches(String title) => title.toLowerCase().contains(_query);

  Future<void> _refresh() async {
    ref.invalidate(myCoursesControllerProvider);
    ref.invalidate(availableCoursesControllerProvider);
    await Future.wait([
      ref.read(myCoursesControllerProvider.future),
      ref.read(availableCoursesControllerProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final myState = ref.watch(myCoursesControllerProvider);
    final availableState = ref.watch(availableCoursesControllerProvider);
    final searching = _query.isNotEmpty;
    // A student who owns nothing gets no "Current courses" section at all.
    final ownsNone = myState.value?.isEmpty ?? false;

    final mine = [
      for (final c in myState.value ?? const <MyCourseEntity>[])
        if (_matches(c.title)) c,
    ];
    final available = [
      for (final c in availableState.value ?? const <CourseEntity>[])
        if (_matches(c.title)) c,
    ];
    final shownMine = searching || _showAllMine
        ? mine
        : mine.take(_myCoursesPreview).toList();
    final shownAvailable = searching || _showAllAvailable
        ? available
        : available.take(_availablePreview).toList();

    // The link reads "See all" until opened, then "Show less"; it only
    // appears when there's more than the preview to see.
    String? toggleLabel(bool open, int count, int preview) =>
        searching || count <= preview
        ? null
        : open
        ? l10n.coursesShowLess
        : l10n.courseSeeAll;

    const sidePadding = EdgeInsets.symmetric(horizontal: AppSpacing.md);

    return ColoredBox(
      color: coursesPageBackground,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md + MediaQuery.paddingOf(context).top,
                AppSpacing.md,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.coursesTitle,
                      style: const TextStyle(
                        color: Color(0xFF15141A),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CoursesSearchField(controller: _search),
                  ],
                ),
              ),
            ),
            // ── Current courses ──
            if (!ownsNone && (!searching || mine.isNotEmpty)) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: CourseSectionHeader(
                    title: l10n.coursesMyCourses,
                    action: toggleLabel(
                      _showAllMine,
                      mine.length,
                      _myCoursesPreview,
                    ),
                    onAction: () =>
                        setState(() => _showAllMine = !_showAllMine),
                  ),
                ),
              ),
              SliverPadding(
                padding: sidePadding,
                sliver: myState.when(
                  loading: () => const _LoadingSliver(),
                  error: (e, _) => _MessageSliver(apiErrorMessage(context, e)),
                  data: (_) {
                    return SliverList.separated(
                      itemCount: shownMine.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) => CurrentCourseCard(
                        key: ValueKey('my-course-${shownMine[i].courseId}'),
                        course: shownMine[i],
                        colorIndex: i,
                        onTap: () => context.push(
                          '/course/${shownMine[i].courseId}?owned=true',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            // ── Available courses ──
            if (!searching || available.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: CourseSectionHeader(
                    title: l10n.coursesAvailable,
                    action: toggleLabel(
                      _showAllAvailable,
                      available.length,
                      _availablePreview,
                    ),
                    onAction: () =>
                        setState(() => _showAllAvailable = !_showAllAvailable),
                  ),
                ),
              ),
              SliverPadding(
                padding: sidePadding,
                sliver: availableState.when(
                  loading: () => const _LoadingSliver(),
                  error: (e, _) => _MessageSliver(apiErrorMessage(context, e)),
                  data: (_) {
                    if (available.isEmpty) {
                      return _MessageSliver(l10n.coursesNoneAvailable);
                    }
                    Widget tile(int i) => AvailableCourseTile(
                      key: ValueKey('available-${shownAvailable[i].id}'),
                      course: shownAvailable[i],
                      colorIndex: i,
                      onTap: () => context.push(
                        '/course/${shownAvailable[i].id}?owned=false',
                      ),
                    );
                    // Two to a row, each row as tall as its taller tile —
                    // a fixed-height grid would clip long titles and
                    // descriptions, and larger system text.
                    final rows = (shownAvailable.length + 1) ~/ 2;
                    return SliverList.separated(
                      itemCount: rows,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, row) {
                        final left = row * 2;
                        final hasRight = left + 1 < shownAvailable.length;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: tile(left)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: hasRight
                                  ? tile(left + 1)
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
            if (searching && mine.isEmpty && available.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: _MessageSliver(l10n.coursesNoResults),
              ),
            // Clear of the floating navbar.
            SliverToBoxAdapter(
              child: SizedBox(
                height: AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSliver extends StatelessWidget {
  const _LoadingSliver();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _MessageSliver extends StatelessWidget {
  final String text;

  const _MessageSliver(this.text);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF6D737E), fontSize: 14),
      ),
    );
  }
}
