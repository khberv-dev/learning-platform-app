import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/router/app_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/app/upgrade/app_upgrade_alert.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.read(appRouterProvider);
    final appTheme = ref.read(appThemeProvider);

    return MaterialApp.router(
      routerConfig: appRouter,
      theme: appTheme,
      // In the builder, so the prompt sits under the Navigator it needs to be
      // pushed onto rather than above it.
      builder: (context, child) => AppUpgradeAlert(
        router: appRouter,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
