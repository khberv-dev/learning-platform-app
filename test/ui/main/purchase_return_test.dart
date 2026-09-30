import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';
import 'package:student/core/payments/presentation/purchase_watcher.dart';
import 'package:student/ui/main/app_screen.dart';

import '../../support/localized_app.dart';

MyCourseEntity _course(String id, String title) => MyCourseEntity(
  enrollmentId: 'en-$id',
  courseId: id,
  title: title,
  lessonsCount: 10,
  progress: 0,
);

class _Courses implements ICoursesRepository {
  /// One entry per call, so a test can model the library changing.
  final List<List<MyCourseEntity>> responses;
  int calls = 0;

  _Courses(this.responses);

  @override
  Future<List<MyCourseEntity>> getMyCourses() async {
    final index = calls < responses.length ? calls : responses.length - 1;
    calls++;
    return responses[index];
  }

  @override
  Future<List<CourseEntity>> getAvailable() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) async => <Never>[];
}

Future<ProviderContainer> _pump(WidgetTester tester, _Courses courses) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [coursesRepositoryProvider.overrideWithValue(courses)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: localizedApp(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => const AppScreen()),
            GoRoute(
              path: '/course/:id',
              builder: (_, state) => Scaffold(
                body: Center(
                  child: Text('course ${state.pathParameters['id']}'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return container;
}

/// Mimics the student returning from the provider's checkout page.
Future<void> _returnToApp(WidgetTester tester) async {
  // Step by step, the way a device reports it: any AppLifecycleListener on
  // screen (e.g. a text field's) rejects a jump straight from paused to
  // resumed.
  for (final state in const [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  // Not pumpAndSettle — the tabs keep a loading spinner running, so nothing
  // ever settles. Timed pumps let the refetch resolve and the dialog animate.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('congratulates when a new course appears after checkout', (
    tester,
  ) async {
    final courses = _Courses([
      [],
      [_course('c1', 'English A1')],
    ]);
    final container = await _pump(tester, courses);

    container
        .read(purchaseWatchProvider.notifier)
        .start(knownCourseIds: const {}, planId: 'pl1');

    await _returnToApp(tester);

    expect(find.text('You’re in!'), findsOneWidget);
    expect(
      find.text('English A1 is now yours. Time to start learning.'),
      findsOneWidget,
    );
    // One-shot — the watch is cleared once it has fired.
    expect(container.read(purchaseWatchProvider), isNull);
  });

  testWidgets('stays quiet when the library has not changed', (tester) async {
    final courses = _Courses([
      [_course('c1', 'English A1')],
    ]);
    final container = await _pump(tester, courses);

    container
        .read(purchaseWatchProvider.notifier)
        .start(knownCourseIds: const {'c1'}, planId: 'pl1');

    await _returnToApp(tester);

    expect(find.text('You’re in!'), findsNothing);
    // Confirmation may still be pending, so it keeps watching.
    expect(container.read(purchaseWatchProvider), isNotNull);
  });

  testWidgets('checks again on a later return', (tester) async {
    final courses = _Courses([
      [], // before checkout
      [], // came back too early, admin hasn't confirmed
      [_course('c2', 'English A2')],
    ]);
    final container = await _pump(tester, courses);

    container
        .read(purchaseWatchProvider.notifier)
        .start(knownCourseIds: const {}, planId: 'pl1');

    await _returnToApp(tester);
    expect(find.text('You’re in!'), findsNothing);

    await _returnToApp(tester);
    expect(find.text('You’re in!'), findsOneWidget);
    expect(
      find.text('English A2 is now yours. Time to start learning.'),
      findsOneWidget,
    );
  });

  testWidgets('ignores resumes when no checkout is in flight', (tester) async {
    final courses = _Courses([
      [_course('c1', 'English A1')],
    ]);
    await _pump(tester, courses);
    final before = courses.calls;

    await _returnToApp(tester);

    // No refetch at all — an ordinary resume must not disturb the library.
    expect(courses.calls, before);
    expect(find.text('You’re in!'), findsNothing);
  });

  testWidgets('opens the purchased course from the dialog', (tester) async {
    final courses = _Courses([
      [],
      [_course('c1', 'English A1')],
    ]);
    final container = await _pump(tester, courses);

    container
        .read(purchaseWatchProvider.notifier)
        .start(knownCourseIds: const {}, planId: 'pl1');
    await _returnToApp(tester);

    await tester.tap(find.text('Start learning'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('course c1'), findsOneWidget);
  });
}
