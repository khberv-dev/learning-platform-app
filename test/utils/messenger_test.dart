import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/shared/widget/app_floating_message.dart';
import 'package:student/utils/messenger.dart';

import '../support/localized_app.dart';

Future<BuildContext> _pump(WidgetTester tester) async {
  late BuildContext context;
  await tester.pumpWidget(
    localizedHome(
      home: Scaffold(
        body: Builder(
          builder: (c) {
            context = c;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  return context;
}

AppFloatingMessage _message(WidgetTester tester) =>
    tester.widget<AppFloatingMessage>(find.byType(AppFloatingMessage));

void main() {
  testWidgets('an error shows its title and detail at the top', (tester) async {
    final context = await _pump(tester);

    showErrorMessage(
      context,
      'Javobingiz xato!',
      detail: 'To‘g‘ri javob: olma — apple',
    );
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
    expect(_message(tester).type, AppMessageType.error);
    expect(find.text('Javobingiz xato!'), findsOneWidget);
    expect(find.text('To‘g‘ri javob: olma — apple'), findsOneWidget);
    final box = tester.getRect(find.byType(AppFloatingMessage));
    expect(box.top, lessThan(tester.view.physicalSize.height / 4));
  });

  testWidgets('slides down from above the screen, then back up', (
    tester,
  ) async {
    final context = await _pump(tester);

    showSuccessMessage(context, 'Saved');
    await tester.pump();
    // Starts entirely above the top edge.
    expect(
      tester.getRect(find.byType(AppFloatingMessage)).bottom,
      lessThanOrEqualTo(0),
    );

    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(AppFloatingMessage)).top,
      greaterThanOrEqualTo(0),
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(AppFloatingMessage), findsNothing);
  });

  testWidgets('swiping up dismisses it early', (tester) async {
    final context = await _pump(tester);

    showErrorMessage(context, 'Oops');
    await tester.pumpAndSettle();
    await tester.fling(
      find.byType(AppFloatingMessage),
      const Offset(0, -200),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppFloatingMessage), findsNothing);
  });

  testWidgets('a success replaces the message already showing', (tester) async {
    final context = await _pump(tester);

    showErrorMessage(context, 'First');
    await tester.pumpAndSettle();
    showSuccessMessage(context, 'Saved');
    await tester.pumpAndSettle();

    expect(find.byType(AppFloatingMessage), findsOneWidget);
    expect(_message(tester).type, AppMessageType.success);
    expect(find.text('First'), findsNothing);
  });

  testWidgets('a title-only message has no detail line', (tester) async {
    await tester.pumpWidget(
      localizedHome(
        home: const Scaffold(
          body: AppFloatingMessage(type: AppMessageType.error, title: 'Oops'),
        ),
      ),
    );

    final texts = find.descendant(
      of: find.byType(AppFloatingMessage),
      matching: find.byType(Text),
    );
    expect(texts, findsOneWidget);
  });
}
