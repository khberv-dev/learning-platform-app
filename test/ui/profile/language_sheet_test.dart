import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/app/locale/locale_controller.dart';
import 'package:student/ui/profile/widget/language_sheet.dart';

import '../../support/localized_app.dart';

Future<ProviderContainer> _openSheet(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [startupLanguageProvider.overrideWithValue(AppLanguage.en)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: localizedHome(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showLanguageSheet(context, AppLanguage.en),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return container;
}

/// The row's `selected` flag, as screen readers get it.
bool _isSelected(WidgetTester tester, AppLanguage language) => tester
    .widget<Semantics>(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == language.label,
      ),
    )
    .properties
    .selected!;

void main() {
  testWidgets('opens as a full-width sheet on the current language', (
    tester,
  ) async {
    await _openSheet(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.getSize(find.byType(BottomSheet)).width, 390);
    expect(find.text('App language'), findsOneWidget);
    for (final language in AppLanguage.values) {
      expect(find.text(language.label), findsOneWidget);
    }
    expect(_isSelected(tester, AppLanguage.en), isTrue);
    expect(_isSelected(tester, AppLanguage.uz), isFalse);
  });

  testWidgets('picking a row only selects it; nothing changes yet', (
    tester,
  ) async {
    final container = await _openSheet(tester);

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();

    expect(_isSelected(tester, AppLanguage.ru), isTrue);
    expect(_isSelected(tester, AppLanguage.en), isFalse);
    expect(container.read(localeControllerProvider), AppLanguage.en);
  });

  testWidgets('Save applies the choice and closes the sheet', (tester) async {
    final container = await _openSheet(tester);

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(container.read(localeControllerProvider), AppLanguage.ru);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('closing without saving leaves the language alone', (
    tester,
  ) async {
    final container = await _openSheet(tester);

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    // Tap the scrim above the sheet.
    await tester.tapAt(const Offset(195, 20));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(container.read(localeControllerProvider), AppLanguage.en);
  });
}
