import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/courses/domain/entity/course_detail_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';
import 'package:student/core/courses/presentation/course_detail_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/courses/unit_screen.dart';

void main() {
  testWidgets('locked lessons show a lock and cannot be opened', (
    tester,
  ) async {
    const course = CourseDetailEntity(
      id: 'course-1',
      title: 'Course',
      lessonsCount: 1,
      price: 0,
      units: [
        UnitEntity(
          id: 'unit-1',
          number: 1,
          title: 'Unit',
          lessonsCount: 1,
          lessons: [
            LessonEntity(
              id: 'lesson-1',
              title: 'Locked lesson',
              isLocked: true,
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseDetailControllerProvider.overrideWith(
            (ref, id) async => course,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: UnitScreen(courseId: 'course-1', unitIndex: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);

    await tester.tap(find.text('Locked lesson'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(UnitScreen), findsOneWidget);
  });
}
