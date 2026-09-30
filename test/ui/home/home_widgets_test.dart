import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/ui/home/widget/home_promo_card.dart';
import 'package:student/ui/home/widget/home_topbar.dart';
import 'package:student/ui/home/widget/streak_card.dart';

import '../../support/localized_app.dart';

Widget _host(Widget child) => localizedHome(
  home: Scaffold(body: Center(child: child)),
);

Widget _topbar(UserEntity? user, {Locale locale = const Locale('en')}) =>
    ProviderScope(
      overrides: [currentUserProvider.overrideWith((ref) => user)],
      child: localizedHome(
        locale: locale,
        home: const Scaffold(body: Center(child: HomeTopbar())),
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

  group('HomePromoCard', () {
    Widget promo({Color background = Colors.white, Color? foreground}) => _host(
      SizedBox(
        width: 342,
        child: HomePromoCard(
          background: background,
          foreground: foreground,
          title: 'No active courses yet',
          subtitle: 'Browse and start learning today',
          buttonLabel: 'Start practice',
          imagePath: 'assets/images/no_course_puppet.png',
          onTap: () {},
        ),
      ),
    );

    testWidgets('picks readable text for light and dark cards', (tester) async {
      await tester.pumpWidget(promo());
      expect(
        tester.widget<Text>(find.text('No active courses yet')).style?.color,
        Colors.black,
      );

      await tester.pumpWidget(promo(background: const Color(0xff1f4a57)));
      expect(
        tester.widget<Text>(find.text('No active courses yet')).style?.color,
        Colors.white,
      );
    });

    testWidgets('an explicit foreground overrides the automatic choice', (
      tester,
    ) async {
      // The brand green reads as "light", so the green card has to force this.
      await tester.pumpWidget(
        promo(background: const Color(0xff18c96a), foreground: Colors.white),
      );

      expect(
        tester.widget<Text>(find.text('No active courses yet')).style?.color,
        Colors.white,
      );
    });

    testWidgets('its action sizes to the label, not the card', (tester) async {
      await tester.pumpWidget(promo());

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(AppButton)).width,
        lessThan(tester.getSize(find.byType(HomePromoCard)).width),
      );
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
