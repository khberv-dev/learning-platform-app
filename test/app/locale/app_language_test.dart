import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/l10n/app_localizations.dart';

void main() {
  test('Uzbek leads, so an unmatched device language falls back to it', () {
    // Flutter resolves an unsupported locale to the first supported one, and
    // `App` builds its supportedLocales from this order.
    expect(AppLanguage.values.first, AppLanguage.uz);
  });

  test('every shipped language has a translation file behind it', () {
    final supported = AppLocalizations.supportedLocales.map(
      (l) => l.languageCode,
    );
    for (final language in AppLanguage.values) {
      expect(supported, contains(language.code), reason: language.name);
    }
  });

  test('stored codes round-trip', () {
    for (final language in AppLanguage.values) {
      expect(AppLanguage.fromCode(language.code), language);
    }
    expect(AppLanguage.fromCode(null), isNull);
    expect(AppLanguage.fromCode('de'), isNull);
  });

  test('a locale matches on its language alone', () {
    // ru_RU and ru are the same choice as far as the app is concerned.
    expect(AppLanguage.fromLocale(const Locale('ru', 'RU')), AppLanguage.ru);
    expect(AppLanguage.fromLocale(const Locale('en')), AppLanguage.en);
    expect(AppLanguage.fromLocale(const Locale('fr')), isNull);
    expect(AppLanguage.fromLocale(null), isNull);
  });

  test('each option names itself, so the picker is readable to anyone', () {
    expect(AppLanguage.uz.label, "O'zbekcha");
    expect(AppLanguage.ru.label, 'Русский');
    expect(AppLanguage.en.label, 'English');
  });
}
