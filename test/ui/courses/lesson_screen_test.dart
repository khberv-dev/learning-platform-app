import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/courses/domain/entity/course_detail_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';
import 'package:student/core/courses/presentation/course_detail_controller.dart';
import 'package:student/core/courses/presentation/tasks_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/courses/lesson_screen.dart';

void main() {
  testWidgets('shows a same-height no-content card when media is null', (
    tester,
  ) async {
    const lesson = LessonEntity(id: 'lesson-1', title: 'Text lesson');
    const lockedLesson = LessonEntity(
      id: 'lesson-2',
      title: 'Locked lesson',
      isLocked: true,
    );
    const course = CourseDetailEntity(
      id: 'course-1',
      title: 'Course',
      lessonsCount: 2,
      price: 0,
      units: [
        UnitEntity(
          id: 'unit-1',
          number: 1,
          title: 'Unit',
          lessonsCount: 2,
          lessons: [lesson, lockedLesson],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseDetailControllerProvider.overrideWith(
            (ref, id) async => course,
          ),
          lessonTaskResultsProvider.overrideWith((ref, id) async => []),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: LessonScreen(
            courseId: 'course-1',
            unitIndex: 0,
            initialLessonIndex: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No content'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('lesson-media-area'))).height,
      200,
    );

    await tester.tap(find.text('Locked lesson'));
    await tester.pump();
    expect(find.text('Unit 01 · Lesson 01'), findsOneWidget);
  });
}
