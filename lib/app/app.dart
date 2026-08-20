import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/app/locale/locale_controller.dart';
import 'package:student/app/router/app_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/app/upgrade/app_upgrade_alert.dart';
import 'package:student/l10n/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.read(appRouterProvider);
    final appTheme = ref.read(appThemeProvider);
    final language = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      routerConfig: appRouter,
      theme: appTheme,
      // Null until the student picks one, which leaves Flutter to match the
      // device language against [supportedLocales] — so the picker itself is
      // already in a language they are likely to read.
      locale: language?.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Uzbek leads, so a device set to something none of the three match
      // falls back to the language most of our students share rather than to
      // English.
      supportedLocales: [for (final l in AppLanguage.values) l.locale],
      // In the builder, so the prompt sits under the Navigator it needs to be
      // pushed onto rather than above it.
      builder: (context, child) => AppUpgradeAlert(
        router: appRouter,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
