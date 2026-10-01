import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/core/assignments/data/repository/assignments_repository.dart';
import 'package:student/core/assignments/domain/entity/assignment_entity.dart';
import 'package:student/core/assignments/domain/repository/i_assignments_repository.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';
import 'package:student/core/groups/data/repository/groups_repository.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/domain/repository/i_groups_repository.dart';
import 'package:student/core/subscriptions/data/repository/subscriptions_repository.dart';
import 'package:student/core/subscriptions/domain/entity/subscription_entity.dart';
import 'package:student/core/subscriptions/domain/repository/i_subscriptions_repository.dart';
import 'package:student/core/user/domain/entity/streak_entity.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/core/user/presentation/streak_provider.dart';
import 'package:student/ui/courses/courses_page.dart';
import 'package:student/ui/profile/profile_page.dart';
import 'package:student/ui/study/study_page.dart';

import '../../support/localized_app.dart';

const _topInset = 47.0;

const _user = UserEntity(
  id: '1',
  firstName: 'Asror',
  phoneNumber: '998900012644',
  points: 0,
  coins: 0,
  level: 'B1',
);

class _Empty
    implements
        ICoursesRepository,
        IGroupsRepository,
        ISubscriptionsRepository,
        IAssignmentsRepository {
  @override
  Future<List<GroupEntity>> getMyGroups() async => [];

  @override
  Future<List<SubscriptionEntity>> getMySubscriptions() async => [];

  @override
  Future<List<AssignmentEntity>> getMyAssignments() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) async => <Never>[];
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
        groupsRepositoryProvider.overrideWithValue(empty),
        subscriptionsRepositoryProvider.overrideWithValue(empty),
        assignmentsRepositoryProvider.overrideWithValue(empty),
        streakProvider.overrideWith((ref) async => _streak),
      ],
      child: localizedApp(
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

const _streak = StreakEntity(
  currentStreak: 25,
  longestStreak: 25,
  totalActiveDays: 40,
  activeToday: true,
  lastActiveDate: null,
);

void main() {
  testWidgets('the courses title clears the status bar', (tester) async {
    await _pump(tester, const CoursesPage());

    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('Courses')).dy,
      greaterThanOrEqualTo(_topInset),
    );
  });

  testWidgets('the study page clears the status bar', (tester) async {
    await _pump(tester, const StudyPage());

    expect(tester.takeException(), isNull);
    expect(
      tester
          .getTopLeft(find.text('Buy a course to choose your lesson times'))
          .dy,
      greaterThanOrEqualTo(_topInset),
    );
  });

  testWidgets('the profile title clears the status bar', (tester) async {
    await _pump(tester, const ProfilePage());

    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('Profile')).dy,
      greaterThanOrEqualTo(_topInset),
    );
  });
}
