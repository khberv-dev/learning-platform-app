import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student/app/upgrade/app_upgrade_alert.dart';
import 'package:student/ui/startup/splash_screen.dart';
import 'package:upgrader/upgrader.dart';

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
Future<GoRouter> _pumpApp(WidgetTester tester) async {
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
    MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => AppUpgradeAlert(
        router: router,
        child: child ?? const SizedBox.shrink(),
      ),
    ),
  );

  // The store lookup and the dialog's own post-frame delay both have to settle.
  await tester.pumpAndSettle();
  return router;
}

/// Stands in for the splash animation ending: the whole stack is replaced,
/// which is what used to take the dialog with it.
Future<void> _leaveSplash(WidgetTester tester, GoRouter router) async {
  router.go(_homePath);
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
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('splash'), findsOneWidget);
  });

  testWidgets('prompts once the splash has handed over', (tester) async {
    final router = await _pumpApp(tester);
    await _leaveSplash(tester, router);

    // Tests run in debug, so the stand-in store applies and the prompt is
    // unconditional — this is the "always show in debug" behaviour.
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('the prompt survives the navigation that raised it', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    await _leaveSplash(tester, router);

    // A few frames on from the hand-over the dialog is still there, rather
    // than having been popped along with the splash page.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('offers a way past it', (tester) async {
    final router = await _pumpApp(tester);
    await _leaveSplash(tester, router);

    // Skippable: both escape hatches are offered alongside the update action.
    expect(find.text('LATER'), findsOneWidget);
    expect(find.text('IGNORE'), findsOneWidget);
    expect(find.text('UPDATE NOW'), findsOneWidget);
  });

  testWidgets('LATER dismisses and leaves the app usable', (tester) async {
    final router = await _pumpApp(tester);
    await _leaveSplash(tester, router);

    await tester.tap(find.text('LATER'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('the release notes blurb is kept out of the prompt', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    await _leaveSplash(tester, router);

    expect(find.textContaining('Release Notes'), findsNothing);
  });

  test(
    'ships unblocked, so the prompt stays skippable until asked otherwise',
    () {
      // Guards the release default: setting this makes the dialog unskippable
      // for older builds, which should never happen by accident.
      expect(minSupportedAppVersion, isNull);
    },
  );

  test('a blocked upgrader would hide the escape hatches', () {
    // Documents the lever rather than the current state: below a minimum, both
    // LATER and IGNORE are dropped by upgrader itself.
    final upgrader = Upgrader(minAppVersion: '99.0.0');
    expect(upgrader.state.minAppVersion.toString(), '99.0.0');
  });
}
