import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/core/startup/presentation/skill_quiz_result_controller.dart';
import 'package:student/core/user/domain/entity/student_level.dart';
import 'package:student/shared/widget/app_option_chip.dart';
import 'package:student/shared/widget/close_icon_button.dart';
import 'package:student/ui/auth/register_screen.dart';
import 'package:student/ui/startup/level_check_screen.dart';
import 'package:student/ui/startup/onboarding_screen.dart';
import 'package:student/ui/startup/skill_level_quiz_screen.dart';
import 'package:student/ui/startup/survey_screen.dart';

const _yes = 'Yes, I have studied some';
const _no = 'No, I am starting from zero';

/// Every destination is stubbed: the point of each test is which one the
/// screen picks, not what it looks like once it gets there.
Future<ProviderContainer> _pumpLevelCheck(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  Widget stub(String label) => Scaffold(body: Center(child: Text(label)));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          initialLocation: LevelCheckScreen.path,
          routes: [
            GoRoute(
              path: LevelCheckScreen.path,
              builder: (_, _) => const LevelCheckScreen(),
            ),
            GoRoute(
              path: SkillLevelQuizScreen.path,
              builder: (_, _) => stub('quiz'),
            ),
            GoRoute(
              path: RegisterScreen.path,
              builder: (_, _) => stub('register'),
            ),
            GoRoute(path: SurveyScreen.path, builder: (_, _) => stub('survey')),
            GoRoute(
              path: OnboardingScreen.path,
              builder: (_, _) => stub('onboarding'),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _answer(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Resume'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Resume stays disabled until an answer is picked', (
    tester,
  ) async {
    await _pumpLevelCheck(tester);

    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    expect(find.text(_yes), findsOneWidget);
    expect(find.text('quiz'), findsNothing);
    expect(find.text('register'), findsNothing);
  });

  testWidgets('a student with some English takes the placement quiz', (
    tester,
  ) async {
    final container = await _pumpLevelCheck(tester);

    await _answer(tester, _yes);

    expect(find.text('quiz'), findsOneWidget);
    // The quiz does the placing, so nothing is decided on the way in.
    expect(container.read(skillQuizResultProvider), isNull);
  });

  testWidgets('a beginner skips the quiz and is placed at A1', (tester) async {
    final container = await _pumpLevelCheck(tester);

    await _answer(tester, _no);

    expect(find.text('register'), findsOneWidget);
    expect(find.text('quiz'), findsNothing);
    expect(container.read(skillQuizResultProvider), StudentLevel.a1);
  });

  testWidgets('answering beginner overwrites a level from an earlier run', (
    tester,
  ) async {
    final container = await _pumpLevelCheck(tester);
    container.read(skillQuizResultProvider.notifier).setLevel(StudentLevel.b2);

    await _answer(tester, _no);

    expect(container.read(skillQuizResultProvider), StudentLevel.a1);
  });

  testWidgets('only one answer is selected at a time', (tester) async {
    await _pumpLevelCheck(tester);

    bool selected(String label) => tester
        .widget<AppOptionChip>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(AppOptionChip),
          ),
        )
        .isSelected;

    await tester.tap(find.text(_yes));
    await tester.pumpAndSettle();
    expect(selected(_yes), isTrue);

    await tester.tap(find.text(_no));
    await tester.pumpAndSettle();
    expect(selected(_no), isTrue);
    expect(selected(_yes), isFalse);
  });

  testWidgets('Back returns to the survey it came from', (tester) async {
    await _pumpLevelCheck(tester);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('survey'), findsOneWidget);
  });

  testWidgets('the close button leaves the flow for onboarding', (
    tester,
  ) async {
    await _pumpLevelCheck(tester);

    await tester.tap(find.byType(CloseIconButton));
    await tester.pumpAndSettle();

    expect(find.text('onboarding'), findsOneWidget);
  });
}
