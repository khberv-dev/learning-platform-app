import 'package:flutter/widgets.dart';

/// The three languages the app ships in.
///
/// Listed the way the audience meets them: Uzbek first, then Russian, then
/// English. The [label]s are endonyms — a language picker is the one screen a
/// student may not be able to read, so each option names itself in its own
/// language rather than in the current UI language.
enum AppLanguage {
  uz('uz', "O'zbekcha", '🇺🇿'),
  ru('ru', 'Русский', '🇷🇺'),
  en('en', 'English', '🇬🇧');

  /// Language subtag, which doubles as the stored value.
  final String code;

  final String label;

  final String flag;

  const AppLanguage(this.code, this.label, this.flag);

  Locale get locale => Locale(code);

  static AppLanguage? fromCode(String? raw) {
    for (final language in values) {
      if (language.code == raw) return language;
    }
    return null;
  }

  /// The language a [Locale] belongs to, ignoring any country or script — `ru`
  /// and `ru_RU` are the same choice as far as this app is concerned.
  static AppLanguage? fromLocale(Locale? locale) =>
      fromCode(locale?.languageCode);
}
