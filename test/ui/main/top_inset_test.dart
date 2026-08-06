import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';
import 'package:student/core/live_lessons/data/repository/live_lessons_repository.dart';
import 'package:student/core/live_lessons/domain/entity/live_lesson_scheduled_entity.dart';
import 'package:student/core/live_lessons/domain/repository/i_live_lessons_repository.dart';
import 'package:student/core/tutors/data/repository/tutors_repository.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/core/tutors/domain/repository/i_tutors_repository.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/ui/courses/courses_page.dart';
import 'package:student/ui/profile/profile_page.dart';
import 'package:student/ui/profile/widget/profile_hero.dart';
import 'package:student/ui/tutors/tutors_page.dart';

const _topInset = 47.0;

const _user = UserEntity(
  id: '1',
  firstName: 'Asror',
  phoneNumber: '998900012644',
  points: 0,
  coins: 0,
  level: 'B1',
  balance: 0,
);

class _Empty implements ICoursesRepository, ITutorsRepository {
  @override
  Future<List<TutorEntity>> getTutors() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) async => <Never>[];
}

class _NoLessons implements ILiveLessonsRepository {
  @override
  Future<List<LiveLessonScheduledEntity>> getMyLessons() async => [];
}

Future<void> _pump(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  tester.view.padding = const FakeViewPadding(top: _topInset * 2);
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  final empty = _Empty();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => _user),
        coursesRepositoryProvider.overrideWithValue(empty),
        tutorsRepositoryProvider.overrideWithValue(empty),
        liveLessonsRepositoryProvider.overrideWithValue(_NoLessons()),
      ],
      child: MaterialApp.router(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          routes: [
            // No SafeArea here, mirroring AppScreen: each page owns its inset.
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(body: page),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('the courses title clears the status bar', (tester) async {
    await _pump(tester, const CoursesPage());

    expect(tester.takeException(), isNull);
    // Scoped to the heading — the tab pill carries the same label.
    expect(
      tester
          .getTopLeft(
            find.descendant(
              of: find.byType(SectionTitle),
              matching: find.text('Courses'),
            ),
          )
          .dy,
      greaterThanOrEqualTo(_topInset),
    );
  });

  testWidgets('the tutors title clears the status bar', (tester) async {
    await _pump(tester, const TutorsPage());

    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('Find a tutor')).dy,
      greaterThanOrEqualTo(_topInset),
    );
  });

  testWidgets('the profile hero deliberately bleeds under it', (tester) async {
    await _pump(tester, const ProfilePage());

    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.byType(ProfileHero)).dy, 0);
  });

  testWidgets('but the profile name still sits clear of the notch', (
    tester,
  ) async {
    await _pump(tester, const ProfilePage());

    // The name hangs at the bottom of the hero, well below the inset.
    expect(tester.getTopLeft(find.text('Asror')).dy, greaterThan(_topInset));
  });
}
