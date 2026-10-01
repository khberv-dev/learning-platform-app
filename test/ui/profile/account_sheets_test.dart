import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/shared/url_launcher.dart';
import 'package:student/shared/widget/app_confirm_sheet.dart';
import 'package:student/shared/widget/app_floating_message.dart';
import 'package:student/ui/profile/widget/settings_card.dart';

import '../../support/localized_app.dart';

/// Records anything the card tries to open externally, so the test can assert
/// the delete flow stays in-app.
class _SpyLauncher {
  final List<Uri> opened = [];

  Future<bool> call(Uri url) async {
    opened.add(url);
    return true;
  }
}

Future<_SpyLauncher> _pumpCard(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final launcher = _SpyLauncher();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [urlLauncherProvider.overrideWithValue(launcher.call)],
      child: localizedHome(
        home: const Scaffold(
          body: SingleChildScrollView(child: SettingsCard()),
        ),
      ),
    ),
  );
  await tester.pump();

  return launcher;
}

Future<void> _open(WidgetTester tester, String row) async {
  await tester.tap(find.text(row));
  await tester.pumpAndSettle();
}

Finder _inSheet(String text) => find.descendant(
  of: find.byType(AppConfirmSheet),
  matching: find.text(text),
);

void main() {
  group('delete account', () {
    testWidgets('asks in a sheet before doing anything', (tester) async {
      final launcher = await _pumpCard(tester);
      await _open(tester, 'Delete account');

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Delete your account?'), findsOneWidget);
      expect(_inSheet('Cancel'), findsOneWidget);
      expect(_inSheet('Delete'), findsOneWidget);
      expect(find.byType(AppFloatingMessage), findsNothing);
      expect(launcher.opened, isEmpty);
    });

    testWidgets('Cancel closes it and leaves nothing behind', (tester) async {
      final launcher = await _pumpCard(tester);
      await _open(tester, 'Delete account');

      await tester.tap(_inSheet('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(AppFloatingMessage), findsNothing);
      expect(launcher.opened, isEmpty);
    });

    testWidgets('Delete files the request and says so', (tester) async {
      final launcher = await _pumpCard(tester);
      await _open(tester, 'Delete account');

      await tester.tap(_inSheet('Delete'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Request sent'), findsOneWidget);
      expect(
        find.textContaining('deletion request has been sent'),
        findsOneWidget,
      );
      // Still an in-app flow — nothing is handed off to a browser.
      expect(launcher.opened, isEmpty);

      // Let the message's auto-hide timer run out.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });

  group('log out', () {
    testWidgets('asks in a sheet first', (tester) async {
      await _pumpCard(tester);
      await _open(tester, 'Log out');

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Log out?'), findsOneWidget);
      expect(_inSheet('Cancel'), findsOneWidget);
      expect(_inSheet('Log out'), findsOneWidget);
    });

    testWidgets('Cancel keeps the student signed in', (tester) async {
      await _pumpCard(tester);
      await _open(tester, 'Log out');

      await tester.tap(_inSheet('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(SettingsCard), findsOneWidget);
    });
  });
}
