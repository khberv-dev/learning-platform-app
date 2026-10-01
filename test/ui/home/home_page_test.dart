import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/core/notifications/presentation/unread_notifications_count_provider.dart';
import 'package:student/core/user/domain/entity/streak_entity.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/domain/usecase/use_get_me.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/core/user/presentation/streak_provider.dart';
import 'package:student/ui/home/home_page.dart';

import '../../support/localized_app.dart';

UserEntity _user(int coins) => UserEntity(
  id: 'u1',
  firstName: 'Azima',
  phoneNumber: '998901234567',
  points: 1240,
  coins: coins,
  level: 'A1',
);

/// Serves `/me` with whatever [coins] is set to at the time.
class _FakeGetMe implements UseGetMe {
  int coins = 320;
  int calls = 0;

  @override
  Future<UserEntity> call() async {
    calls++;
    return _user(coins);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Mine extends MyCoursesController {
  static int builds = 0;

  @override
  Future<List<MyCourseEntity>> build() async {
    builds++;
    return const [];
  }
}

class _Available extends AvailableCoursesController {
  static int builds = 0;

  @override
  Future<List<CourseEntity>> build() async {
    builds++;
    return const [];
  }
}

void main() {
  testWidgets('pulling down reloads the page, including the student', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    _Mine.builds = 0;
    _Available.builds = 0;
    var streakBuilds = 0;
    var unreadBuilds = 0;
    final getMe = _FakeGetMe();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => _user(320)),
          useGetMeProvider.overrideWithValue(getMe),
          streakProvider.overrideWith((ref) async {
            streakBuilds++;
            return const StreakEntity(
              currentStreak: 3,
              longestStreak: 3,
              totalActiveDays: 3,
              activeToday: true,
              lastActiveDate: null,
            );
          }),
          unreadNotificationsCountProvider.overrideWith((ref) async {
            unreadBuilds++;
            return 0;
          }),
          myCoursesControllerProvider.overrideWith(_Mine.new),
          availableCoursesControllerProvider.overrideWith(_Available.new),
        ],
        child: localizedHome(home: const Scaffold(body: HomePage())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('320'), findsOneWidget);
    expect(getMe.calls, 0);

    // The server now says 400 coins.
    getMe.coins = 400;
    await tester.fling(
      find.byType(SingleChildScrollView),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(getMe.calls, 1);
    expect(find.text('400'), findsOneWidget);
    expect(streakBuilds, 2);
    expect(unreadBuilds, 2);
    expect(_Mine.builds, 2);
    expect(_Available.builds, 2);
  });
}
