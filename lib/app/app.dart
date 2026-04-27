import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/router/app_router.dart';
import 'package:student/app/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.read(appRouterProvider);
    final appTheme = ref.read(appThemeProvider);

    return MaterialApp.router(routerConfig: appRouter, theme: appTheme);
  }
}
