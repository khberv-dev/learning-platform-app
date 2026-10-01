import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/core/subscriptions/domain/entity/subscription_entity.dart';
import 'package:student/core/subscriptions/presentation/my_subscriptions_controller.dart';
import 'package:student/core/user/domain/entity/streak_entity.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/core/user/presentation/streak_provider.dart';
import 'package:student/ui/plans/plans_screen.dart';
import 'package:student/ui/profile/profile_page.dart';

import '../../support/localized_app.dart';

class _Subs extends MySubscriptionsController {
  final List<SubscriptionEntity> subs;
  _Subs(this.subs);

  @override
  Future<List<SubscriptionEntity>> build() async => subs;
}

const _user = UserEntity(
  id: 'u1',
  firstName: 'Samiya',
  lastName: 'Azimova',
  phoneNumber: '998901234567',
  points: 1240,
  coins: 320,
  level: 'A1',
);

SubscriptionEntity _sub(String courseTitle, {required int endsInDays}) {
  final end = DateTime.now().add(Duration(days: endsInDays));
  return SubscriptionEntity(
    id: 's-$courseTitle',
    course: SubscriptionCourseEntity(id: 'c-$courseTitle', title: courseTitle),
    start: end.subtract(const Duration(days: 30)),
    end: end,
    isActive: true,
  );
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  List<SubscriptionEntity> subs,
) async {
  tester.view.physicalSize = const Size(390, 1600) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      currentUserProvider.overrideWith((ref) => _user),
      mySubscriptionsControllerProvider.overrideWith(() => _Subs(subs)),
      streakProvider.overrideWith((ref) async => _streak),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: localizedApp(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: ProfilePage()),
            ),
            GoRoute(
              path: PlansScreen.path,
              builder: (_, state) => Scaffold(
                body: Text('plans ${state.uri.queryParameters['courseId']}'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

const _streak = StreakEntity(
  currentStreak: 25,
  longestStreak: 25,
  totalActiveDays: 40,
  activeToday: true,
  lastActiveDate: null,
);

void main() {
  testWidgets('shows the student with their full, unmasked phone', (
    tester,
  ) async {
    await _pump(tester, []);

    expect(tester.takeException(), isNull);
    expect(find.text('Samiya Azimova'), findsOneWidget);
    expect(find.text('+998 90 123 45 67'), findsOneWidget);
  });

  testWidgets('a running plan shows its course, badge and end date', (
    tester,
  ) async {
    await _pump(tester, [_sub('General English', endsInDays: 20)]);

    expect(find.text('Current plan'), findsOneWidget);
    expect(find.text('General English'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Ends on'), findsOneWidget);
    expect(find.byKey(const ValueKey('plan-none')), findsNothing);
  });

  testWidgets('every running plan gets its own card', (tester) async {
    await _pump(tester, [
      _sub('General English', endsInDays: 20),
      _sub('IELTS', endsInDays: 40),
      _sub('Old course', endsInDays: -10),
    ]);

    expect(find.text('Active'), findsNWidgets(2));
    expect(find.text('Old course'), findsNothing);
  });

  testWidgets('no plan offers one and opens Courses', (tester) async {
    final container = await _pump(tester, []);

    expect(find.text('No active plan'), findsOneWidget);
    await tester.tap(find.text('Choose a plan'));
    await tester.pump();

    expect(container.read(navbarControllerProvider), 1);
  });

  testWidgets('all plans expired offers renewing the last one', (tester) async {
    await _pump(tester, [
      _sub('General English', endsInDays: -30),
      _sub('IELTS', endsInDays: -2),
    ]);

    expect(find.text('IELTS plan has expired'), findsOneWidget);
    await tester.tap(find.text('Renew plan'));
    await tester.pumpAndSettle();

    expect(find.text('plans c-IELTS'), findsOneWidget);
  });

  testWidgets('shows XP, coins, and settings and account rows', (tester) async {
    await _pump(tester, []);

    expect(find.text('25 days'), findsOneWidget);
    expect(find.text('1 240'), findsOneWidget);
    expect(find.text('320'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('App language'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
  });

  testWidgets('tapping the header opens the account sheet', (tester) async {
    await _pump(tester, []);

    await tester.tap(find.text('Samiya Azimova'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Change photo'), findsOneWidget);
  });
}
