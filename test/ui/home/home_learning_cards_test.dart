import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/shared/widget/course_tiles.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/ui/ai_assessment/ai_speaking_partner_screen.dart';
import 'package:student/ui/home/widget/home_learning_cards.dart';
import 'package:student/ui/p2p/p2p_matchmaking_screen.dart';

import '../../support/localized_app.dart';

class _Available extends AvailableCoursesController {
  final List<CourseEntity> courses;
  _Available(this.courses);

  @override
  Future<List<CourseEntity>> build() async => courses;
}

class _Mine extends MyCoursesController {
  final List<MyCourseEntity> courses;
  _Mine(this.courses);

  @override
  Future<List<MyCourseEntity>> build() async => courses;
}

MyCourseEntity _course(String id, String title, double progress) =>
    MyCourseEntity(
      enrollmentId: 'e-$id',
      courseId: id,
      title: title,
      lessonsCount: 8,
      progress: progress,
    );

Future<void> _pump(
  WidgetTester tester, {
  List<MyCourseEntity> mine = const [],
  List<CourseEntity> available = const [],
  VoidCallback? onSeeAll,
}) async {
  tester.view.physicalSize = const Size(390, 1400) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  Widget page(String text) => Scaffold(body: Text(text));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myCoursesControllerProvider.overrideWith(() => _Mine(mine)),
        availableCoursesControllerProvider.overrideWith(
          () => _Available(available),
        ),
      ],
      child: localizedApp(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      const HomeCourseCards(),
                      const HomePracticeTiles(),
                      HomeCoursesCarousel(onSeeAll: onSeeAll ?? () {}),
                    ],
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/course/:id',
              builder: (_, state) => page(
                'course ${state.pathParameters['id']} '
                '${state.uri.queryParameters['owned']}',
              ),
            ),
            GoRoute(
              path: AiSpeakingPartnerScreen.path,
              builder: (_, _) => page('ai partner'),
            ),
            GoRoute(
              path: P2pMatchmakingScreen.path,
              builder: (_, _) => page('matchmaking'),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('owning no course shows no course card', (tester) async {
    await _pump(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(HomeCourseCard), findsNothing);
    // The practice tiles are there regardless.
    expect(find.text('AI partner'), findsOneWidget);
    expect(find.text('Speaking partner'), findsOneWidget);
  });

  testWidgets('one card per owned course, with its progress', (tester) async {
    await _pump(
      tester,
      mine: [
        _course('c1', 'Everyday English', 0.34),
        _course('c2', 'IELTS', 0.8),
      ],
    );

    expect(find.byType(HomeCourseCard), findsNWidgets(2));
    expect(find.text('34%'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('8 lessons'), findsNWidgets(2));
  });

  testWidgets('Resume opens the course as owned', (tester) async {
    await _pump(tester, mine: [_course('c1', 'Everyday English', 0.34)]);

    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(find.text('course c1 true'), findsOneWidget);
  });

  testWidgets('the AI tile opens the AI partner', (tester) async {
    await _pump(tester);

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('home-ai-partner')),
        matching: find.textContaining('Go to'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('home-ai-partner')));
    await tester.pumpAndSettle();
    expect(find.text('ai partner'), findsOneWidget);
  });

  testWidgets('the partner tile opens matchmaking', (tester) async {
    await _pump(tester);

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('home-find-partner')),
        matching: find.textContaining('Go to'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('home-find-partner')));
    await tester.pumpAndSettle();
    expect(find.text('matchmaking'), findsOneWidget);
  });

  testWidgets('the two tiles fit side by side on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900) * 2;
    tester.view.devicePixelRatio = 2;
    await _pump(tester);
    tester.view.physicalSize = const Size(320, 900) * 2;
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  group('courses carousel', () {
    const onSale = [
      CourseEntity(
        id: 'a1',
        title: 'General English',
        imageUrl: 'https://storage.example/a1.jpg',
        description: 'For beginners',
        lessonsCount: 24,
        durationHours: 6,
      ),
      CourseEntity(id: 'a2', title: 'CEFR prep'),
      CourseEntity(id: 'a3', title: 'IELTS prep'),
    ];

    testWidgets('hidden when nothing is on sale', (tester) async {
      await _pump(tester);

      expect(find.text('Courses'), findsNothing);
      expect(find.byType(AvailableCourseTile), findsNothing);
    });

    testWidgets('shows every course on sale, with its banner', (tester) async {
      await _pump(tester, available: onSale);

      expect(find.text('Courses'), findsOneWidget);
      expect(find.byType(AvailableCourseTile), findsNWidgets(3));
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('home-course-tile-a1')),
          matching: find.byKey(const ValueKey('course-cover-image')),
        ),
        findsOneWidget,
      );
      expect(find.text('24 lessons'), findsOneWidget);
    });

    testWidgets('scrolls sideways', (tester) async {
      await _pump(tester, available: onSale);

      final carousel = find.byKey(const ValueKey('home-courses-carousel'));
      final before = tester.getTopLeft(
        find.byKey(const ValueKey('home-course-tile-a1')),
      );
      await tester.drag(carousel, const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.byKey(const ValueKey('home-course-tile-a1'))).dx,
        lessThan(before.dx),
      );
    });

    testWidgets('See all and a tile both lead on', (tester) async {
      var seeAll = 0;
      await _pump(tester, available: onSale, onSeeAll: () => seeAll++);

      await tester.tap(find.text('See all'));
      await tester.pump();
      expect(seeAll, 1);

      await tester.tap(find.byKey(const ValueKey('home-course-tile-a2')));
      await tester.pumpAndSettle();
      expect(find.text('course a2 false'), findsOneWidget);
    });
  });
}
