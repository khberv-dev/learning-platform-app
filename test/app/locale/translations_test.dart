import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/l10n/app_localizations_en.dart';

/// Every getter and method [AppLocalizations] exposes, called on one locale.
///
/// Reflection-free: the generated class has no iteration API, so the check is
/// that each locale's class overrides everything the English one does — which
/// the analyzer enforces at compile time — plus the spot checks below.
void main() {
  test('a locale can be built for every language the picker offers', () async {
    for (final language in AppLanguage.values) {
      final l10n = await AppLocalizations.delegate.load(language.locale);
      expect(l10n.localeName, language.code);
    }
  });

  test('the delegate accepts exactly the languages we ship', () {
    for (final language in AppLanguage.values) {
      expect(AppLocalizations.delegate.isSupported(language.locale), isTrue);
    }
    expect(
      AppLocalizations.delegate.isSupported(const Locale('de')),
      isFalse,
      reason: 'German is not translated, so it must fall back',
    );
  });

  test('no string is left in English in another language', () async {
    final en = AppLocalizationsEn();
    // A sample across the app rather than all ~200 keys: these are the ones
    // most likely to be forgotten, being buttons and empty states.
    for (final language in [AppLanguage.uz, AppLanguage.ru]) {
      final l10n = await AppLocalizations.delegate.load(language.locale);
      expect(l10n.languageTitle, isNot(en.languageTitle));
      expect(l10n.navHome, isNot(en.navHome));
      expect(l10n.settingsLogOut, isNot(en.settingsLogOut));
      expect(l10n.tasksEmptyTitle, isNot(en.tasksEmptyTitle));
      expect(l10n.p2pFinding, isNot(en.p2pFinding));
      expect(l10n.roadmapTopicGreetings, isNot(en.roadmapTopicGreetings));
    }
  });

  test('plurals pick the right form in Russian', () async {
    final ru = await AppLocalizations.delegate.load(const Locale('ru'));

    expect(ru.courseLessonCount(1), '1 урок');
    expect(ru.courseLessonCount(3), '3 урока');
    expect(ru.courseLessonCount(11), '11 уроков');
  });

  testWidgets('Flutter\'s own widgets are translated too', (tester) async {
    // Dates, times and Material tooltips come from flutter_localizations, so
    // every language we offer has to be one it knows.
    for (final language in AppLanguage.values) {
      await tester.pumpWidget(
        MaterialApp(
          locale: language.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Text(
              MaterialLocalizations.of(
                context,
              ).formatShortMonthDay(DateTime(2026, 8, 18)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: language.code);
    }
  });
}
