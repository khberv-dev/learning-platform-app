import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/app/locale/locale_controller.dart';
import 'package:student/app/locale/locale_storage.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/ui/startup/language_screen.dart';
import 'package:student/ui/startup/onboarding_screen.dart';

import '../../support/localized_app.dart';

/// Pumps the picker on its own router, with [OnboardingScreen.path] stubbed as
/// the destination it was handed.
Future<ProviderContainer> _pumpPicker(
  WidgetTester tester, {
  String next = OnboardingScreen.path,
  Locale deviceLocale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: localizedApp(
        theme: container.read(appThemeProvider),
        locale: deviceLocale,
        routerConfig: GoRouter(
          initialLocation: languageRouteFor(next),
          routes: [
            GoRoute(
              path: LanguageScreen.path,
              builder: (_, state) => LanguageScreen(
                next: state.uri.queryParameters['next'] ?? languageDefaultNext,
              ),
            ),
            GoRoute(
              path: OnboardingScreen.path,
              builder: (_, _) =>
                  const Scaffold(body: Center(child: Text('onboarding'))),
            ),
            GoRoute(
              path: '/app',
              builder: (_, _) =>
                  const Scaffold(body: Center(child: Text('app'))),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('offers all three languages, each named in itself', (
    tester,
  ) async {
    await _pumpPicker(tester);

    expect(find.text("O'zbekcha"), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('opens on the language the device already resolved to', (
    tester,
  ) async {
    await _pumpPicker(tester, deviceLocale: const Locale('ru'));

    // Russian device, Russian copy — before anything is picked.
    expect(find.text('Выберите язык'), findsOneWidget);
  });

  testWidgets('tapping a language stores it and carries on to `next`', (
    tester,
  ) async {
    final container = await _pumpPicker(tester, next: '/app');

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();

    expect(container.read(localeControllerProvider), AppLanguage.ru);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('the choice survives the next launch', (tester) async {
    final container = await _pumpPicker(tester);

    await tester.tap(find.text("O'zbekcha"));
    await tester.pumpAndSettle();

    // What `main` reads before the first frame of the next run.
    expect(
      await container.read(localeStorageProvider).getLanguage(),
      AppLanguage.uz,
    );
  });

  testWidgets('without an explicit next, lands on onboarding', (tester) async {
    await _pumpPicker(tester, next: languageDefaultNext);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('onboarding'), findsOneWidget);
  });
}
