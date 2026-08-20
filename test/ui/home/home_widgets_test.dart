import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/l10n/app_localizations_en.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/ui/home/widget/home_promo_card.dart';
import 'package:student/ui/home/widget/home_topbar.dart';
import 'package:student/ui/home/widget/stats_row.dart';
import 'package:student/ui/home/widget/streak_card.dart';

import '../../support/localized_app.dart';

final _l10n = AppLocalizationsEn();

Widget _host(Widget child) => localizedHome(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('levelLabel', () {
    test('maps CEFR levels to plain language', () {
      expect(levelLabel(_l10n, 'A1'), 'Beginner');
      expect(levelLabel(_l10n, 'a2'), 'Beginner');
      expect(levelLabel(_l10n, 'B1'), 'Intermediate');
      expect(levelLabel(_l10n, 'B2'), 'Intermediate');
      expect(levelLabel(_l10n, 'C1'), 'Advanced');
      expect(levelLabel(_l10n, 'C2'), 'Advanced');
    });

    test('passes through anything unrecognised', () {
      expect(levelLabel(_l10n, ''), '');
      expect(levelLabel(_l10n, 'D9'), 'D9');
    });
  });

  group('ordinal', () {
    test('uses the right suffix', () {
      expect(ordinal(1), '1st');
      expect(ordinal(2), '2nd');
      expect(ordinal(3), '3rd');
      expect(ordinal(4), '4th');
      expect(ordinal(6), '6th');
      expect(ordinal(21), '21st');
      expect(ordinal(102), '102nd');
    });

    test('teens are all th, not st/nd/rd', () {
      expect(ordinal(11), '11th');
      expect(ordinal(12), '12th');
      expect(ordinal(13), '13th');
      expect(ordinal(111), '111th');
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
    testWidgets('ticks only the completed days', (tester) async {
      await tester.pumpWidget(
        _host(
          const StreakCard(
            days: 3,
            week: [true, true, false, true, false, false, false],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
    });

    testWidgets('renders no ticks for an empty week', (tester) async {
      await tester.pumpWidget(
        _host(const StreakCard(days: 0, week: StreakCard.emptyWeek)),
      );

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('a short week list still lays out seven cells', (tester) async {
      await tester.pumpWidget(
        _host(const StreakCard(days: 2, week: [true, true])),
      );

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
    });

    testWidgets('formats large streaks with a thousands separator', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const StreakCard(days: 1200, week: StreakCard.emptyWeek)),
      );

      // Grouped by the locale now — a comma in English, a space in uz/ru.
      expect(find.text('1,200 days'), findsOneWidget);
    });
  });
}
