import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student/app/locale/app_language.dart';

final localeStorageProvider = Provider((ref) => LocaleStorage());

/// Remembers the language the student picked, in the same `SharedPreferences`
/// the tokens live in.
///
/// Absent means "never asked", which is what sends the splash screen to the
/// language picker rather than straight into the app.
class LocaleStorage {
  static const _languageKey = 'app_language';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _storage async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<AppLanguage?> getLanguage() async =>
      AppLanguage.fromCode((await _storage).getString(_languageKey));

  Future<void> saveLanguage(AppLanguage language) async =>
      (await _storage).setString(_languageKey, language.code);
}
