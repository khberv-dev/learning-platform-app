import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/shared/url_launcher.dart';
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

Future<void> _tapDeleteAccount(WidgetTester tester) async {
  await tester.tap(find.text('Delete account'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('asks before doing anything', (tester) async {
    final launcher = await _pumpCard(tester);
    await _tapDeleteAccount(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
    // The confirmation must not be on screen yet.
    expect(find.text('Request sent'), findsNothing);
    expect(launcher.opened, isEmpty);
  });

  testWidgets('answering no closes it and leaves nothing behind', (
    tester,
  ) async {
    final launcher = await _pumpCard(tester);
    await _tapDeleteAccount(tester);

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Request sent'), findsNothing);
    expect(launcher.opened, isEmpty);
  });

  testWidgets('answering yes swaps in the acknowledgement', (tester) async {
    final launcher = await _pumpCard(tester);
    await _tapDeleteAccount(tester);

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    // The prompt is gone and exactly one dialog remains.
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Request sent'), findsOneWidget);
    expect(find.text('Yes'), findsNothing);
    expect(
      find.textContaining('deletion request has been sent'),
      findsOneWidget,
    );
    // Still an in-app flow — nothing is handed off to a browser.
    expect(launcher.opened, isEmpty);
  });

  testWidgets('the acknowledgement dismisses', (tester) async {
    await _pumpCard(tester);
    await _tapDeleteAccount(tester);

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
