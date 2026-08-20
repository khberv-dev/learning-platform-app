import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/ui/auth/forgot_password_screen.dart';
import 'package:student/ui/auth/login_screen.dart';

import '../../support/localized_app.dart';

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    ProviderScope(
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
}
