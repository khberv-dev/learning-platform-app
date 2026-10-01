import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/notifications/presentation/unread_notifications_count_provider.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/ui/home/widget/home_topbar.dart';
import 'package:student/ui/home/widget/streak_card.dart';
import 'package:student/ui/notifications/notifications_screen.dart';

import '../../support/localized_app.dart';

Widget _topbar(
  UserEntity? user, {
  Locale locale = const Locale('en'),
  int unread = 0,
}) => ProviderScope(
  overrides: [
    currentUserProvider.overrideWith((ref) => user),
    unreadNotificationsCountProvider.overrideWith((ref) async => unread),
  ],
  child: localizedApp(
    locale: locale,
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Center(child: HomeTopbar())),
        ),
        GoRoute(
          path: NotificationsScreen.path,
          builder: (_, _) => const Scaffold(body: Text('notifications page')),
        ),
      ],
    ),
  ),
);

const _azima = UserEntity(
  id: 'u1',
  firstName: 'Azima',
  lastName: 'Karimova',
  phoneNumber: '998901234567',
  points: 1250,
  coins: 7,
  level: 'A1',
);

void main() {
  group('HomeTopbar', () {
    testWidgets('greets the student by first name', (tester) async {
      await tester.pumpWidget(_topbar(_azima));

      expect(tester.takeException(), isNull);
      expect(find.text('Good day,'), findsOneWidget);
      expect(find.text('Azima!'), findsOneWidget);
    });

    testWidgets('greets in the chosen language', (tester) async {
      await tester.pumpWidget(_topbar(_azima, locale: const Locale('uz')));

      expect(find.text('Hayrli kun,'), findsOneWidget);
    });

    testWidgets('shows points and coins in their chips', (tester) async {
      await tester.pumpWidget(_topbar(_azima));

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('home-points')),
          matching: find.text('1 250'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('home-coins')),
          matching: find.text('7'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the bell shows a dot while something is unread', (
      tester,
    ) async {
      await tester.pumpWidget(_topbar(_azima, unread: 3));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('notifications-unread-dot')),
        findsOneWidget,
      );
    });

    testWidgets('and no dot once everything is read', (tester) async {
      await tester.pumpWidget(_topbar(_azima));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('notifications-unread-dot')),
        findsNothing,
      );
    });

    testWidgets('the bell opens notifications', (tester) async {
      await tester.pumpWidget(_topbar(_azima));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('notifications page'), findsOneWidget);
    });

    testWidgets('no photo shows the person placeholder', (tester) async {
      await tester.pumpWidget(_topbar(_azima));

      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });

    testWidgets('a long name and big balances fit on a narrow screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640) * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _topbar(
          const UserEntity(
            id: 'u1',
            firstName: 'Muhammadamin Abdurahmonov',
            phoneNumber: '998901234567',
            points: 1234567,
            coins: 98765,
            level: 'A1',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('StreakCard', () {
    Widget card(int days, {Locale locale = const Locale('en')}) =>
        localizedHome(
          locale: locale,
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 342, child: StreakCard(days: days)),
            ),
          ),
        );

    String mascot(WidgetTester tester) =>
        (tester.widget<Image>(find.byKey(const ValueKey('streak-mascot'))).image
                as AssetImage)
            .assetName;

    testWidgets('invites a student with no streak to start one', (
      tester,
    ) async {
      await tester.pumpWidget(card(0, locale: const Locale('uz')));

      expect(tester.takeException(), isNull);
      expect(find.text('Seriyani boshlang'), findsOneWidget);
      expect(
        find.text('Birinchi darsni tugatib, seriyangizni yoqing'),
        findsOneWidget,
      );
      expect(mascot(tester), 'assets/images/mascot_streak_0.png');
    });

    testWidgets('a running streak shows its length', (tester) async {
      await tester.pumpWidget(card(3));

      expect(find.text('3 days'), findsOneWidget);
      expect(find.text("Don't forget me!"), findsOneWidget);
      expect(mascot(tester), 'assets/images/mascot_streak_1.png');
    });

    test('the mascot changes at 1, 20 and 30 days', () {
      expect(StreakCard.mascotFor(0), 'assets/images/mascot_streak_0.png');
      expect(StreakCard.mascotFor(1), 'assets/images/mascot_streak_1.png');
      expect(StreakCard.mascotFor(19), 'assets/images/mascot_streak_1.png');
      expect(StreakCard.mascotFor(20), 'assets/images/mascot_streak_20.png');
      expect(StreakCard.mascotFor(29), 'assets/images/mascot_streak_20.png');
      expect(StreakCard.mascotFor(30), 'assets/images/mascot_streak_30.png');
      expect(StreakCard.mascotFor(365), 'assets/images/mascot_streak_30.png');
    });

    testWidgets('the mascot rises above the card without covering the '
        'content above it', (tester) async {
      await tester.pumpWidget(card(0));

      final whole = tester.getRect(find.byType(StreakCard));
      final mascotRect = tester.getRect(
        find.byKey(const ValueKey('streak-mascot')),
      );
      expect(mascotRect.top, greaterThanOrEqualTo(whole.top));
      final panel = tester.getRect(
        find.descendant(
          of: find.byType(StreakCard),
          matching: find.byType(Container),
        ),
      );
      expect(mascotRect.top, lessThan(panel.top));
    });

    testWidgets('formats large streaks with a thousands separator', (
      tester,
    ) async {
      await tester.pumpWidget(card(1200));

      // Grouped by the locale — a comma in English, a space in uz/ru.
      expect(find.text('1,200 days'), findsOneWidget);
    });
  });
}
