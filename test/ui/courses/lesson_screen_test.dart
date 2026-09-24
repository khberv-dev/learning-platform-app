import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/courses/domain/entity/lesson_detail_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/presentation/course_detail_controller.dart';
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
    const lessonDetail = LessonDetailEntity(
      id: 'lesson-1',
      title: 'Text lesson',
      taskProgression: TaskProgressionEntity(
        totalTasks: 0,
        completedTasks: 0,
        progressPercent: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unitLessonsProvider.overrideWith(
            (ref, params) async => [lesson, lockedLesson],
          ),
          lessonDetailProvider.overrideWith((ref, params) async {
            return lessonDetail;
          }),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: LessonScreen(
            courseId: 'course-1',
            unitId: 'unit-1',
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
