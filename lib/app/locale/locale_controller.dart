import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/app/locale/locale_storage.dart';

/// The language stored on the device, read once before the first frame.
///
/// Overridden in `main` with the value from [LocaleStorage]; the default here
/// is what tests and any un-overridden container see — nobody has chosen yet.
final startupLanguageProvider = Provider<AppLanguage?>((ref) => null);

/// The student's chosen language, or null while they have not chosen one.
///
/// Null is a meaningful state, not a loading one: the app runs in the device's
/// language until the choice is made, and the splash screen sends anyone still
/// null to the language picker.
final localeControllerProvider =
    NotifierProvider<LocaleController, AppLanguage?>(LocaleController.new);

class LocaleController extends Notifier<AppLanguage?> {
  @override
  AppLanguage? build() => ref.read(startupLanguageProvider);

  /// Applies [language] to the running app and remembers it for next launch.
  ///
  /// The UI switches on the state change without waiting for the write — a
  /// storage failure should not hold up the tap that caused it.
  Future<void> select(AppLanguage language) async {
    state = language;
    await ref.read(localeStorageProvider).saveLanguage(language);
  }
}
