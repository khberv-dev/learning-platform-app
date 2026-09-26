import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student/app/upgrade/app_upgrade_alert.dart';
import 'package:student/ui/startup/splash_screen.dart';

import '../support/localized_app.dart';

const _homePath = '/home';

/// The alert reads the installed version through package_info_plus and its
/// "asked recently" bookkeeping through shared_preferences, neither of whose
/// platform channels exists under the test binding.
void _stubPlugins() {
  PackageInfo.setMockInitialValues(
    appName: 'iTeach',
    packageName: 'uz.iteach.student',
    version: '0.0.10',
    buildNumber: '10',
    buildSignature: '',
    installerStore: null,
  );
  SharedPreferences.setMockInitialValues({});
}

/// Stands in for the real app: a router that starts on the splash route, with
/// the alert mounted from the builder exactly as `App` mounts it.
Future<GoRouter> _pumpApp(
  WidgetTester tester, {
  bool dismissible = true,
  List<Uri>? opened,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: SplashScreen.path,
        builder: (_, _) => const Scaffold(body: Text('splash')),
      ),
      GoRoute(
        path: _homePath,
        builder: (_, _) => const Scaffold(body: Text('home')),
      ),
    ],
  );

  await tester.pumpWidget(
    localizedApp(
      routerConfig: router,
      builder: (context, child) => AppUpgradeAlert(
        router: router,
        dismissible: dismissible,
        openStore: (url) async {
          opened?.add(url);
          return true;
        },
        child: child ?? const SizedBox.shrink(),
      ),
    ),
  );

  // The store lookup and the sheet's own post-frame delay both have to settle.
  await tester.pumpAndSettle();
  return router;
}

/// Stands in for the splash animation ending: the whole stack is replaced,
/// which is what used to take the prompt with it.
Future<void> _leaveSplash(WidgetTester tester, GoRouter router) async {
  router.go(_homePath);
  await tester.pumpAndSettle();
}

final _sheet = find.text('A new version is available');

/// Taps the scrim above the sheet.
Future<void> _tapOutside(WidgetTester tester) async {
  await tester.tapAt(const Offset(195, 60));
  await tester.pumpAndSettle();
}

void main() {
  setUp(_stubPlugins);

  testWidgets('holds the prompt back while the splash screen is up', (
    tester,
  ) async {
    await _pumpApp(tester);

    // Prompting here would be prompting into the void: the splash replaces the
    // route stack when its animation ends, and upgrader never offers twice.
    expect(_sheet, findsNothing);
    expect(find.text('splash'), findsOneWidget);
  });

  testWidgets('prompts with the update sheet once the splash has handed over', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    await _leaveSplash(tester, router);

    // Tests run in debug, so the stand-in store applies and the prompt is
    // unconditional — this is the "always show in debug" behaviour.
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(_sheet, findsOneWidget);
    expect(
      find.text(
        'A new version of the app is ready. Update now to enjoy the latest '
        'features.',
      ),
      findsOneWidget,
    );
    expect(find.text('Update'), findsOneWidget);
    // One way forward — none of upgrader's stock Later / Ignore buttons.
    expect(find.text('LATER'), findsNothing);
    expect(find.text('IGNORE'), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('the prompt survives the navigation that raised it', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    await _leaveSplash(tester, router);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(_sheet, findsOneWidget);
  });

  testWidgets('in debug, tapping outside dismisses it', (tester) async {
    final router = await _pumpApp(tester);
    await _leaveSplash(tester, router);

    await _tapOutside(tester);

    expect(_sheet, findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('in debug, back dismisses it', (tester) async {
    final router = await _pumpApp(tester);
    await _leaveSplash(tester, router);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(_sheet, findsNothing);
  });

  testWidgets('does not reappear on a later app resume', (tester) async {
    final router = await _pumpApp(tester);
    await _leaveSplash(tester, router);
    await _tapOutside(tester);
    expect(_sheet, findsNothing);

    // `Upgrader` re-checks on every resume (`checkOnResume` defaults to
    // true) — regressing to `debugDisplayAlways` would force it back up here.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(_sheet, findsNothing);
  });

  testWidgets('when not dismissible, neither the scrim nor back closes it', (
    tester,
  ) async {
    final router = await _pumpApp(tester, dismissible: false);
    await _leaveSplash(tester, router);

    await _tapOutside(tester);
    expect(_sheet, findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_sheet, findsOneWidget);

    // Nor a drag down on the sheet.
    await tester.drag(_sheet, const Offset(0, 500));
    await tester.pumpAndSettle();
    expect(_sheet, findsOneWidget);
  });

  testWidgets('Update opens the Play Store listing on Android', (tester) async {
    final opened = <Uri>[];
    final router = await _pumpApp(tester, opened: opened);
    await _leaveSplash(tester, router);

    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    expect(opened, [Uri.parse(playStoreUrl)]);
    // Dismissible (debug), so it gets out of the way once the store opens.
    expect(_sheet, findsNothing);
  });

  testWidgets('Update opens the App Store listing on iOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final opened = <Uri>[];
    final router = await _pumpApp(tester, opened: opened);
    await _leaveSplash(tester, router);

    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;

    expect(opened, [Uri.parse(appStoreUrl)]);
  });

  testWidgets('when not dismissible, the sheet stays up behind the store', (
    tester,
  ) async {
    final opened = <Uri>[];
    final router = await _pumpApp(tester, dismissible: false, opened: opened);
    await _leaveSplash(tester, router);

    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    expect(opened, hasLength(1));
    expect(_sheet, findsOneWidget);
  });

  test('dismissible by default only in debug builds', () {
    final alert = AppUpgradeAlert(
      router: GoRouter(routes: []),
      child: const SizedBox(),
    );
    expect(alert.dismissible, kDebugMode);
  });
}
