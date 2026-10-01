import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/ui/ai_assessment/ai_speaking_partner_screen.dart';

import '../../support/localized_app.dart';

Future<void> _pump(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: AiSpeakingPartnerScreen.path,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('home')),
        routes: const [],
      ),
      GoRoute(
        path: AiSpeakingPartnerScreen.path,
        builder: (_, _) => const AiSpeakingPartnerScreen(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      child: localizedApp(locale: locale, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens on the intro', (tester) async {
    await _pump(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('AI partner'), findsOneWidget);
    expect(find.text('Live conversation with AI'), findsOneWidget);
    expect(find.text('You can end it whenever you like'), findsOneWidget);
    expect(
      find.text('A live voice conversation, in real time'),
      findsOneWidget,
    );
    expect(find.text('No grades or points — just talk'), findsOneWidget);
    expect(find.text('Start talking'), findsOneWidget);
    expect(
      find.text('The conversation needs access to your microphone.'),
      findsOneWidget,
    );
    // No call yet, so nothing to end.
    expect(find.text('End conversation'), findsNothing);
  });

  testWidgets('reads in Uzbek', (tester) async {
    await _pump(tester, locale: const Locale('uz'));

    expect(find.text('AI suhbatdosh'), findsOneWidget);
    expect(find.text('AI bilan jonli suhbat'), findsOneWidget);
    expect(find.text('Suhbatni boshlash'), findsOneWidget);
  });

  testWidgets('fits a small phone without overflowing', (tester) async {
    await _pump(tester);
    tester.view.physicalSize = const Size(320, 568) * 2;
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
