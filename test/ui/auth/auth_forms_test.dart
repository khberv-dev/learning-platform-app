import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/shared/url_launcher.dart';
import 'package:student/ui/auth/forgot_password_screen.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/auth/register_screen.dart';

import '../../support/localized_app.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: localizedApp(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          routes: [GoRoute(path: '/', builder: (_, _) => screen)],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('LoginScreen', () {
    testWidgets('blocks submit and reports invalid input', (tester) async {
      await _pump(tester, const LoginScreen());

      // An empty form must not reach the controller (which would hit the API).
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid phone number'), findsOneWidget);
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('fixing the phone clears its error on the next submit', (
      tester,
    ) async {
      await _pump(tester, const LoginScreen());

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid phone number'), findsOneWidget);

      // Errors are only recomputed on submit — typing alone leaves the
      // message up, which is Flutter's default AutovalidateMode.disabled.
      await tester.enterText(find.byType(TextFormField).at(0), '901234567');
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid phone number'), findsOneWidget);

      // Password is still invalid, so submit stops there — but the phone
      // error is gone.
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid phone number'), findsNothing);
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('password starts hidden', (tester) async {
      await _pump(tester, const LoginScreen());

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen', () {
    testWidgets('requires the confirmation to match', (tester) async {
      await _pump(tester, const ForgotPasswordScreen());

      await tester.enterText(find.byType(TextFormField).at(0), '901234567');
      await tester.enterText(find.byType(TextFormField).at(1), 'hunter2hunter');
      await tester.enterText(find.byType(TextFormField).at(2), 'different-one');
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('has a show/hide toggle on both password fields', (
      tester,
    ) async {
      await _pump(tester, const ForgotPasswordScreen());

      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    });
  });

  group('RegisterScreen legal notice', () {
    Future<List<Uri>> pumpRegister(
      WidgetTester tester, {
      bool launchSucceeds = true,
    }) async {
      final opened = <Uri>[];
      await _pump(
        tester,
        const RegisterScreen(),
        overrides: [
          inAppBrowserLauncherProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return launchSucceeds;
          }),
        ],
      );
      return opened;
    }

    // The legal notice sits at the bottom of the form, below the fold now
    // that the gender picker adds height — scroll it into view first.
    Future<void> scrollToLegalNotice(WidgetTester tester) async {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await tester.pumpAndSettle();
    }

    testWidgets('opens the public offer', (tester) async {
      final opened = await pumpRegister(tester);
      await scrollToLegalNotice(tester);

      await tester.tapOnText(find.textRange.ofSubstring('Public Offer'));
      await tester.pumpAndSettle();

      expect(opened, [Uri.parse(publicOfferUrl)]);
    });

    testWidgets('opens the privacy policy', (tester) async {
      final opened = await pumpRegister(tester);
      await scrollToLegalNotice(tester);

      await tester.tapOnText(find.textRange.ofSubstring('Privacy Policy'));
      await tester.pumpAndSettle();

      expect(opened, [Uri.parse(privacyPolicyUrl)]);
    });

    testWidgets('reports a document that could not be opened', (tester) async {
      await pumpRegister(tester, launchSucceeds: false);
      await scrollToLegalNotice(tester);

      await tester.tapOnText(find.textRange.ofSubstring('Privacy Policy'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't open the document"), findsOneWidget);
    });
  });
}
