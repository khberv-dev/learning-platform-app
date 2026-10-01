import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/ui/courses/courses_page.dart';
import 'package:student/shared/widget/course_tiles.dart';
import 'package:student/ui/courses/widget/courses_page_cards.dart';

import '../../support/localized_app.dart';

class _Mine extends MyCoursesController {
  final List<MyCourseEntity> courses;
  _Mine(this.courses);

  @override
  Future<List<MyCourseEntity>> build() async => courses;
}

class _Available extends AvailableCoursesController {
  final List<CourseEntity> courses;
  _Available(this.courses);

  @override
  Future<List<CourseEntity>> build() async => courses;
}

MyCourseEntity _mine(String id, String title, {double progress = 0.34}) =>
    MyCourseEntity(
      enrollmentId: 'e-$id',
      courseId: id,
      title: title,
      lessonsCount: 8,
      progress: progress,
    );

CourseEntity _course(String id, String title) => CourseEntity(
  id: id,
  title: title,
  description: '$title description',
  lessonsCount: 24,
  durationHours: 6,
);

final _sixOnSale = [
  _course('a1', 'General English'),
  _course('a2', 'CEFR prep'),
  _course('a3', 'IELTS prep'),
  _course('a4', 'Grammar basics'),
  _course('a5', 'Speaking English'),
  _course('a6', 'Business English'),
];

Future<void> _pump(
  WidgetTester tester, {
  List<MyCourseEntity> mine = const [],
  List<CourseEntity>? available,
}) async {
  tester.view.physicalSize = const Size(390, 2400) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myCoursesControllerProvider.overrideWith(() => _Mine(mine)),
        availableCoursesControllerProvider.overrideWith(
          () => _Available(available ?? _sixOnSale),
        ),
      ],
      child: localizedApp(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: CoursesPage()),
            ),
            GoRoute(
              path: '/course/:id',
              builder: (_, state) => Scaffold(
                body: Text(
                  'course ${state.pathParameters['id']} '
                  '${state.uri.queryParameters['owned']}',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the current course with its progress', (tester) async {
    await _pump(tester, mine: [_mine('m1', 'Everyday English')]);

    expect(tester.takeException(), isNull);
    expect(find.text('Current courses'), findsOneWidget);
    expect(find.byType(CurrentCourseCard), findsOneWidget);
    expect(find.text('34%'), findsOneWidget);
    expect(find.text('8 lessons'), findsOneWidget);
  });

  testWidgets('courses on sale show four, then all on "See all"', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(AvailableCourseTile), findsNWidgets(4));
    expect(find.text('24 lessons'), findsNWidgets(4));
    expect(find.text('6 hours'), findsNWidgets(4));

    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.byType(AvailableCourseTile), findsNWidgets(6));

    await tester.tap(find.text('Show less'));
    await tester.pumpAndSettle();
    expect(find.byType(AvailableCourseTile), findsNWidgets(4));
  });

  testWidgets('several current courses preview one', (tester) async {
    await _pump(
      tester,
      mine: [_mine('m1', 'Everyday English'), _mine('m2', 'IELTS')],
      available: const [],
    );

    expect(find.byType(CurrentCourseCard), findsOneWidget);
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.byType(CurrentCourseCard), findsNWidgets(2));
  });

  testWidgets('no "See all" when everything already fits', (tester) async {
    await _pump(
      tester,
      mine: [_mine('m1', 'Everyday English')],
      available: _sixOnSale.take(3).toList(),
    );

    expect(find.text('See all'), findsNothing);
  });

  testWidgets('search filters both lists by title', (tester) async {
    await _pump(tester, mine: [_mine('m1', 'Everyday English')]);

    await tester.enterText(
      find.byKey(const ValueKey('courses-search')),
      'english',
    );
    await tester.pumpAndSettle();

    expect(find.byType(CurrentCourseCard), findsOneWidget);
    // "General", "Speaking" and "Business English" — past the preview of
    // four would still show them all, since a search shows every match.
    expect(find.byType(AvailableCourseTile), findsNWidgets(3));
    expect(find.text('CEFR prep'), findsNothing);
  });

  testWidgets('a search with no match says so', (tester) async {
    await _pump(tester, mine: [_mine('m1', 'Everyday English')]);

    await tester.enterText(find.byKey(const ValueKey('courses-search')), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No courses found'), findsOneWidget);
    expect(find.text('Current courses'), findsNothing);
  });

  testWidgets('owning no course hides the current-courses section', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(CurrentCourseCard), findsNothing);
    expect(find.text('Current courses'), findsNothing);
    expect(find.text('No active courses yet'), findsNothing);
    expect(find.text('Available courses'), findsOneWidget);
  });

  testWidgets('a course without counts leaves its chips out', (tester) async {
    await _pump(
      tester,
      available: const [CourseEntity(id: 'x', title: 'Plain course')],
    );

    expect(find.text('Plain course'), findsWidgets);
    expect(find.textContaining('lessons'), findsNothing);
  });

  testWidgets('a course with a banner shows it instead of the gradient', (
    tester,
  ) async {
    await _pump(
      tester,
      available: const [
        CourseEntity(
          id: 'b',
          title: 'Bannered',
          imageUrl: 'https://storage.example/banner.jpg',
        ),
        CourseEntity(id: 'p', title: 'Plain'),
      ],
    );

    final banner = find.descendant(
      of: find.byKey(const ValueKey('available-b')),
      matching: find.byKey(const ValueKey('course-cover-image')),
    );
    expect(banner, findsOneWidget);
    expect(
      (tester.widget<Image>(banner).image as NetworkImage).url,
      'https://storage.example/banner.jpg',
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('available-p')),
        matching: find.byKey(const ValueKey('course-cover-image')),
      ),
      findsNothing,
    );
  });

  testWidgets('tapping a card opens its course page', (tester) async {
    await _pump(tester, mine: [_mine('m1', 'Everyday English')]);

    await tester.tap(find.byType(CurrentCourseCard));
    await tester.pumpAndSettle();
    expect(find.text('course m1 true'), findsOneWidget);
  });

  testWidgets('tapping a course on sale opens it as not owned', (tester) async {
    await _pump(tester);

    await tester.tap(find.byKey(const ValueKey('available-a2')));
    await tester.pumpAndSettle();
    expect(find.text('course a2 false'), findsOneWidget);
  });
}
