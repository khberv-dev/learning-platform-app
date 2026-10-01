import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/courses/domain/entity/lesson_detail_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/presentation/course_detail_controller.dart';
import 'package:student/core/user/presentation/activity_recorder.dart';
import 'package:student/ui/courses/lesson_screen.dart';
import 'package:student/ui/courses/tasks_screen.dart';

import '../../support/localized_app.dart';

const _noTasks = TaskProgressionEntity(
  totalTasks: 0,
  completedTasks: 0,
  progressPercent: 0,
);

class _NoopRecorder implements ActivityRecorder {
  int calls = 0;

  @override
  Future<void> record() async => calls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

const _unit = [
  LessonEntity(
    id: 'lesson-1',
    title: 'Intro',
    duration: Duration(seconds: 50),
    progressPercent: 100,
  ),
  LessonEntity(
    id: 'lesson-2',
    title: 'Vowels',
    duration: Duration(minutes: 2, seconds: 10),
    progressPercent: 79,
  ),
  LessonEntity(id: 'lesson-3', title: 'Consonants', isLocked: true),
];

/// The detail's own score for each lesson — lesson-1 passed, the rest not.
LessonDetailEntity _detailFor(String id) => LessonDetailEntity(
  id: id,
  title: 'Detail of $id',
  taskProgression: TaskProgressionEntity(
    totalTasks: 5,
    completedTasks: 5,
    progressPercent: id == 'lesson-1' ? 90 : 40,
  ),
);

Finder _inRow(int i, Finder finder) => find.descendant(
  of: find.byKey(ValueKey('unit-lesson-$i')),
  matching: finder,
);

Future<_NoopRecorder> _pump(
  WidgetTester tester, {
  LessonDetailEntity? detail,
  Future<LessonDetailEntity> Function(String lessonId)? loadDetail,
  List<LessonEntity> lessons = const [
    LessonEntity(id: 'lesson-1', title: 'Alphabet'),
  ],
}) async {
  tester.view.physicalSize = const Size(390, 1200) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final recorder = _NoopRecorder();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        unitLessonsProvider.overrideWith((ref, params) async => lessons),
        lessonDetailProvider.overrideWith(
          (ref, params) async =>
              await loadDetail?.call(params.lessonId) ??
              detail ??
              _detailFor(params.lessonId),
        ),
        activityRecorderProvider.overrideWithValue(recorder),
      ],
      child: localizedApp(
        routerConfig: GoRouter(
          initialLocation: '/lesson',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: Text('course')),
            ),
            GoRoute(
              path: '/lesson',
              builder: (_, _) => const LessonScreen(
                courseId: 'course-1',
                unitId: 'unit-1',
                unitIndex: 0,
                initialLessonIndex: 0,
              ),
            ),
            GoRoute(
              path: TasksScreen.path,
              builder: (_, state) => Scaffold(
                body: Text('tasks ${state.uri.queryParameters['lessonId']}'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return recorder;
}

void main() {
  testWidgets('a lesson without media says so in a 16:9 area', (tester) async {
    await _pump(
      tester,
      detail: const LessonDetailEntity(
        id: 'lesson-1',
        title: 'English alphabet',
        taskProgression: _noTasks,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('No content'), findsOneWidget);
    final area = tester.getSize(
      find.byKey(const ValueKey('lesson-media-area')),
    );
    expect(area.width / area.height, closeTo(16 / 9, 0.01));
  });

  testWidgets('the video starts at the very top, under the status bar', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(top: 47 * 2);
    await _pump(
      tester,
      detail: const LessonDetailEntity(
        id: 'lesson-1',
        title: 'English alphabet',
        taskProgression: _noTasks,
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('lesson-media-area'))).dy,
      0,
    );
  });

  testWidgets("lists the unit's lessons with their lengths", (tester) async {
    await _pump(tester, lessons: _unit);

    expect(find.text('Lessons'), findsOneWidget);
    expect(find.text('Intro'), findsOneWidget);
    expect(find.text('00:50'), findsOneWidget);
    expect(find.text('Vowels'), findsOneWidget);
    expect(find.text('02:10'), findsOneWidget);
    expect(find.text('Consonants'), findsOneWidget);
    // Numbered on the left.
    expect(_inRow(0, find.text('1')), findsOneWidget);
    expect(_inRow(1, find.text('2')), findsOneWidget);
    expect(_inRow(2, find.text('3')), findsOneWidget);
    // On the right: a tick once passed (80%+), nothing below, a padlock.
    expect(_inRow(0, find.byKey(const ValueKey('lesson-passed'))), findsOne);
    expect(
      _inRow(1, find.byKey(const ValueKey('lesson-passed'))),
      findsNothing,
    );
    expect(_inRow(2, find.byKey(const ValueKey('lesson-locked'))), findsOne);
    // The lesson on screen has the glowing border.
    expect(_inRow(0, find.byKey(const ValueKey('lesson-current'))), findsOne);
    expect(
      _inRow(1, find.byKey(const ValueKey('lesson-current'))),
      findsNothing,
    );
  });

  testWidgets('tapping another lesson switches to it in place', (tester) async {
    await _pump(tester, lessons: _unit);
    expect(find.text('Detail of lesson-1'), findsOneWidget);

    await tester.tap(find.text('Vowels'));
    await tester.pumpAndSettle();

    expect(find.byType(LessonScreen), findsOneWidget);
    expect(find.text('Detail of lesson-2'), findsOneWidget);
    expect(_inRow(1, find.byKey(const ValueKey('lesson-current'))), findsOne);
    expect(
      _inRow(0, find.byKey(const ValueKey('lesson-current'))),
      findsNothing,
    );
  });

  testWidgets('a locked lesson stays put', (tester) async {
    await _pump(tester, lessons: _unit);

    await tester.tap(find.text('Consonants'));
    await tester.pumpAndSettle();

    expect(find.text('Detail of lesson-1'), findsOneWidget);
  });

  testWidgets('a single-lesson unit has no lesson list', (tester) async {
    await _pump(tester);

    expect(find.text('Lessons'), findsNothing);
  });

  testWidgets('Go to the test opens the tasks and counts as activity', (
    tester,
  ) async {
    final recorder = await _pump(
      tester,
      detail: const LessonDetailEntity(
        id: 'lesson-1',
        title: 'English alphabet',
        taskProgression: _noTasks,
      ),
    );

    await tester.tap(find.text('Go to the test'));
    await tester.pumpAndSettle();

    expect(find.text('tasks lesson-1'), findsOneWidget);
    expect(recorder.calls, 1);
  });

  testWidgets('the lesson on screen uses its own, fresher score', (
    tester,
  ) async {
    // The list still says 0% for lesson-1, but its detail scores 90%.
    await _pump(
      tester,
      lessons: const [
        LessonEntity(id: 'lesson-1', title: 'Intro', progressPercent: 0),
        LessonEntity(id: 'lesson-2', title: 'Vowels'),
      ],
    );

    expect(_inRow(0, find.byKey(const ValueKey('lesson-passed'))), findsOne);
  });

  testWidgets('switching lessons keeps the screen while the next one loads', (
    tester,
  ) async {
    final next = Completer<LessonDetailEntity>();
    await _pump(
      tester,
      lessons: _unit,
      loadDetail: (id) async => id == 'lesson-2' ? next.future : _detailFor(id),
    );

    await tester.tap(find.text('Vowels'));
    await tester.pump();

    // Still the same screen: the old lesson, the list, and only a spinner
    // where the video goes — no full-screen loader.
    expect(find.text('Detail of lesson-1'), findsOneWidget);
    expect(find.text('Lessons'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('lesson-media-area')),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // The list already shows the new choice.
    expect(_inRow(1, find.byKey(const ValueKey('lesson-current'))), findsOne);

    next.complete(_detailFor('lesson-2'));
    await tester.pumpAndSettle();

    expect(find.text('Detail of lesson-2'), findsOneWidget);
    expect(find.text('Detail of lesson-1'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
