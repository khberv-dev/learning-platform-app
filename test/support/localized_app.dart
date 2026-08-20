import 'package:flutter/material.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/l10n/app_localizations.dart';

/// The localisation setup `App` gives every screen at runtime.
///
/// Screens read `AppLocalizations.of(context)`, which throws under a bare
/// [MaterialApp], so tests that pump one go through here. English by default,
/// since that is what the assertions are written in; pass [locale] to check a
/// screen in another language.
MaterialApp localizedApp({
  required RouterConfig<Object> routerConfig,
  ThemeData? theme,
  Locale locale = const Locale('en'),
  TransitionBuilder? builder,
}) {
  return MaterialApp.router(
    routerConfig: routerConfig,
    theme: theme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: [
      for (final language in AppLanguage.values) language.locale,
    ],
    builder: builder,
  );
}

/// [localizedApp] for the screens that don't need a router.
MaterialApp localizedHome({
  required Widget home,
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    home: home,
    theme: theme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: [
      for (final language in AppLanguage.values) language.locale,
    ],
  );
}
