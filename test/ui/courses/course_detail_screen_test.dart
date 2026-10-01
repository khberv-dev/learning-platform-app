import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/courses/domain/entity/course_author_entity.dart';
import 'package:student/core/courses/domain/entity/course_detail_entity.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';
import 'package:student/core/courses/presentation/course_detail_controller.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/courses/course_detail_screen.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/ui/courses/lesson_screen.dart';
import 'package:student/ui/plans/plans_screen.dart';

import '../../support/localized_app.dart';

const _course = CourseDetailEntity(
  id: 'c1',
  title: 'General English',
  description: 'A beginner-friendly English course.',
  totalProgress: 40,
  authors: [
    CourseAuthorEntity(
      id: 'a1',
      firstName: 'Dilnoza',
      lastName: 'Rahimova',
      description: 'Ten years teaching beginners.',
    ),
  ],
);

const _units = [
  UnitEntity(id: 'u1', title: 'Alphabet', lessonsCount: 3),
  UnitEntity(id: 'u2', title: 'Greetings', lessonsCount: 3),
  UnitEntity(id: 'u3', title: 'To be', lessonsCount: 4, isLocked: true),
];

class _FakeAvailable extends AvailableCoursesController {
  @override
  Future<List<CourseEntity>> build() async => const [
    CourseEntity(id: 'c1', title: 'General English'),
    CourseEntity(
      id: 'c2',
      title: 'Everyday English',
      description: 'Daily conversations',
    ),
  ];
}

Future<void> _pump(WidgetTester tester, {required bool owned}) async {
  tester.view.physicalSize = const Size(390, 1600) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => CourseDetailScreen(courseId: 'c1', isOwned: owned),
      ),
      GoRoute(
        path: LessonScreen.path,
        builder: (_, state) => Scaffold(
          body: Text(
            'lesson ${state.uri.queryParameters['unitId']}'
            ' #${state.uri.queryParameters['lessonIndex']}',
          ),
        ),
      ),
      GoRoute(
        path: PlansScreen.path,
        builder: (_, _) => const Scaffold(body: Text('plans page')),
      ),
      GoRoute(
        path: '/course/:id',
        builder: (_, state) =>
            Scaffold(body: Text('course ${state.pathParameters['id']}')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        courseDetailControllerProvider.overrideWith((ref, id) async => _course),
        courseUnitsProvider.overrideWith((ref, id) async => _units),
        unitLessonsProvider.overrideWith(
          (ref, params) async => params.unitId == 'u2'
              ? const [
                  LessonEntity(
                    id: 'l1',
                    title: 'Saying hello',
                    description: 'Hi, hello, good morning',
                  ),
                  LessonEntity(id: 'l2', title: 'Introductions'),
                  LessonEntity(id: 'l3', title: 'Small talk', isLocked: true),
                ]
              : const [],
        ),
        availableCoursesControllerProvider.overrideWith(_FakeAvailable.new),
      ],
      child: localizedApp(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _locks() => find.byKey(const ValueKey('module-lock'));

void main() {
  testWidgets('shows the course, its teacher and modules', (tester) async {
    await _pump(tester, owned: false);

    expect(tester.takeException(), isNull);
    expect(find.text('General English'), findsWidgets);
    expect(find.text('10 lessons'), findsOneWidget);
    expect(find.text('3 modules'), findsOneWidget);
    expect(find.text('About the course'), findsOneWidget);
    expect(find.text('Dilnoza Rahimova'), findsOneWidget);
    expect(find.text('Alphabet'), findsOneWidget);
  });

  group('not owned', () {
    testWidgets('every module is locked and there is no progress', (
      tester,
    ) async {
      await _pump(tester, owned: false);

      expect(_locks(), findsNWidgets(3));
      expect(find.byKey(const ValueKey('course-progress')), findsNothing);
    });

    testWidgets('the buy button and a module both lead to plans', (
      tester,
    ) async {
      await _pump(tester, owned: false);

      await tester.tap(find.widgetWithText(AppFlatPillButton, 'Buy a plan'));
      await tester.pumpAndSettle();
      expect(find.text('plans page'), findsOneWidget);
    });
  });

  group('owned', () {
    testWidgets('open modules are numbered, locked ones keep the lock', (
      tester,
    ) async {
      await _pump(tester, owned: true);

      expect(find.text('01'), findsOneWidget);
      expect(find.text('02'), findsOneWidget);
      expect(_locks(), findsOneWidget);
    });

    testWidgets('shows progress and no buy button', (tester) async {
      await _pump(tester, owned: true);

      expect(find.byKey(const ValueKey('course-progress')), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('Buy a plan'), findsNothing);
    });

    testWidgets('an open module swaps in its lessons, in place', (
      tester,
    ) async {
      await _pump(tester, owned: true);

      await tester.tap(find.text('Greetings'));
      await tester.pumpAndSettle();

      // Still the course page — no new screen.
      expect(find.byType(CourseDetailScreen), findsOneWidget);
      expect(find.text('Modules'), findsNothing);
      expect(find.text('Alphabet'), findsNothing);
      expect(find.text('Saying hello'), findsOneWidget);
      expect(find.text('Hi, hello, good morning'), findsOneWidget);
      expect(find.text('Introductions'), findsOneWidget);
      expect(find.byKey(const ValueKey('lesson-lock')), findsOneWidget);
    });

    testWidgets('the arrow beside the module goes back to the list', (
      tester,
    ) async {
      await _pump(tester, owned: true);
      await tester.tap(find.text('Greetings'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('unit-back')));
      await tester.pumpAndSettle();

      expect(find.text('Modules'), findsOneWidget);
      expect(find.text('Saying hello'), findsNothing);
    });

    testWidgets('back closes the module before leaving the course', (
      tester,
    ) async {
      await _pump(tester, owned: true);
      await tester.tap(find.text('Greetings'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(CourseDetailScreen), findsOneWidget);
      expect(find.text('Modules'), findsOneWidget);
    });

    testWidgets('an open lesson opens the lesson screen', (tester) async {
      await _pump(tester, owned: true);
      await tester.tap(find.text('Greetings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Introductions'));
      await tester.pumpAndSettle();
      expect(find.text('lesson u2 #1'), findsOneWidget);
    });

    testWidgets('a locked lesson goes nowhere', (tester) async {
      await _pump(tester, owned: true);
      await tester.tap(find.text('Greetings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Small talk'));
      await tester.pumpAndSettle();
      expect(find.byType(CourseDetailScreen), findsOneWidget);
      expect(find.text('Small talk'), findsOneWidget);
    });

    testWidgets('a locked module goes nowhere', (tester) async {
      await _pump(tester, owned: true);

      await tester.tap(find.text('To be'));
      await tester.pumpAndSettle();
      expect(find.byType(CourseDetailScreen), findsOneWidget);
    });
  });

  testWidgets('the teacher card opens their bio', (tester) async {
    await _pump(tester, owned: true);

    await tester.tap(find.text('Dilnoza Rahimova'));
    await tester.pumpAndSettle();
    expect(find.text('Ten years teaching beginners.'), findsOneWidget);
  });

  testWidgets('the bio sheet spans the full width, even on a tablet', (
    tester,
  ) async {
    await _pump(tester, owned: true);
    // Wider than Material 3's 640 cap on bottom sheets.
    tester.view.physicalSize = const Size(900, 1600) * 2;
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dilnoza Rahimova'));
    await tester.pumpAndSettle();

    final sheet = tester.getRect(find.byType(BottomSheet));
    expect(sheet.width, 900);
    expect(tester.takeException(), isNull);
  });

  testWidgets('other courses leave out this one and open on tap', (
    tester,
  ) async {
    await _pump(tester, owned: true);

    expect(find.text('Other courses'), findsOneWidget);
    expect(find.text('Everyday English'), findsNWidgets(2));
    expect(find.text('Daily conversations'), findsOneWidget);

    await tester.tap(find.text('Daily conversations'));
    await tester.pumpAndSettle();
    expect(find.text('course c2'), findsOneWidget);
  });
}
