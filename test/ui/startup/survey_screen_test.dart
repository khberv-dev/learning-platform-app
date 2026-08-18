import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/shared/widget/app_option_chip.dart';
import 'package:student/shared/widget/close_icon_button.dart';
import 'package:student/ui/startup/level_check_screen.dart';
import 'package:student/ui/startup/onboarding_screen.dart';
import 'package:student/ui/startup/survey_screen.dart';

Future<void> _pumpSurvey(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    MaterialApp.router(
      theme: container.read(appThemeProvider),
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const SurveyScreen())],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('close button leaves the survey for onboarding', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          initialLocation: SurveyScreen.path,
          routes: [
            GoRoute(
              path: SurveyScreen.path,
              builder: (_, _) => const SurveyScreen(),
            ),
            GoRoute(
              path: OnboardingScreen.path,
              builder: (_, _) =>
                  const Scaffold(body: Center(child: Text('onboarding'))),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Career Growth'), findsOneWidget);

    await tester.tap(find.byType(CloseIconButton));
    await tester.pumpAndSettle();

    expect(find.text('onboarding'), findsOneWidget);
    expect(find.text('Career Growth'), findsNothing);
  });

  testWidgets('first question is single-select', (tester) async {
    await _pumpSurvey(tester);

    bool selected(String label) => tester
        .widget<AppOptionChip>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(AppOptionChip),
          ),
        )
        .isSelected;

    await tester.tap(find.text('Career Growth'));
    await tester.pumpAndSettle();
    expect(selected('Career Growth'), isTrue);

    await tester.tap(find.text('Immigration'));
    await tester.pumpAndSettle();
    expect(selected('Immigration'), isTrue);
    expect(selected('Career Growth'), isFalse);
  });

  testWidgets('Resume stays disabled until something is picked', (
    tester,
  ) async {
    await _pumpSurvey(tester);

    // Nothing selected — tapping Resume must not advance.
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(find.text('Career Growth'), findsOneWidget);
    expect(find.text('5 minutes'), findsNothing);

    await tester.tap(find.text('Career Growth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(find.text('5 minutes'), findsOneWidget);
  });

  testWidgets('single-select question replaces the previous choice', (
    tester,
  ) async {
    await _pumpSurvey(tester);

    await tester.tap(find.text('Career Growth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    expect(find.text('5 minutes'), findsOneWidget);

    bool selected(String label) => tester
        .widget<AppOptionChip>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(AppOptionChip),
          ),
        )
        .isSelected;

    await tester.tap(find.text('5 minutes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 minutes'));
    await tester.pumpAndSettle();

    expect(selected('30 minutes'), isTrue);
    expect(selected('5 minutes'), isFalse);
  });

  testWidgets('Back returns to the previous question, keeping answers', (
    tester,
  ) async {
    await _pumpSurvey(tester);

    await tester.tap(find.text('Career Growth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Career Growth'), findsOneWidget);
    expect(
      tester
          .widget<AppOptionChip>(
            find.ancestor(
              of: find.text('Career Growth'),
              matching: find.byType(AppOptionChip),
            ),
          )
          .isSelected,
      isTrue,
    );
  });

  testWidgets('the last question hands over to the level check', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          initialLocation: SurveyScreen.path,
          routes: [
            GoRoute(
              path: SurveyScreen.path,
              builder: (_, _) => const SurveyScreen(),
            ),
            GoRoute(
              path: LevelCheckScreen.path,
              builder: (_, _) =>
                  const Scaffold(body: Center(child: Text('level check'))),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final answer in ['Career Growth', '15 minutes']) {
      await tester.tap(find.text(answer));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
    }

    // Not the placement quiz: whether that is worth running is the level
    // check's question to ask.
    expect(find.text('level check'), findsOneWidget);
  });

  testWidgets('options alternate left and right alignment', (tester) async {
    await _pumpSurvey(tester);
    await tester.tap(find.text('Career Growth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    // Second question's labels are short enough that chips don't fill the row.
    final first = tester.getTopLeft(
      find.ancestor(
        of: find.text('5 minutes'),
        matching: find.byType(AppOptionChip),
      ),
    );
    final second = tester.getTopLeft(
      find.ancestor(
        of: find.text('15 minutes'),
        matching: find.byType(AppOptionChip),
      ),
    );

    expect(second.dx, greaterThan(first.dx));
  });
}
