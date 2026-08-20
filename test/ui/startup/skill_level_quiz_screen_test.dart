import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/core/startup/data/repository/quiz_repository.dart';
import 'package:student/shared/widget/app_option_chip.dart';
import 'package:student/ui/startup/skill_level_quiz_screen.dart';

import '../../support/localized_app.dart';

const _longOption =
    'He likes to play a tennis with his friends every single weekend.';

class _FakeQuizRepository implements QuizRepository {
  @override
  Future<List<Map<String, dynamic>>> loadQuiz() async => [
    {
      'question': 'What are his hobbies?',
      'options': [
        'He tennis playing likes.',
        'He likes playing tennis.',
        _longOption,
      ],
      'correct': 'He likes playing tennis.',
    },
    {
      'question': 'Where do you live? I live __ London.',
      'options': ['in', 'on', 'at'],
      'correct': 'in',
    },
  ];
}

Future<void> _pumpQuiz(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        quizRepositoryProvider.overrideWithValue(_FakeQuizRepository()),
      ],
      child: localizedApp(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => const SkillLevelQuizScreen()),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

bool _isSelected(WidgetTester tester, String label) => tester
    .widget<AppOptionChip>(
      find.ancestor(of: find.text(label), matching: find.byType(AppOptionChip)),
    )
    .isSelected;

void main() {
  testWidgets('shows no question counter', (tester) async {
    await _pumpQuiz(tester);

    expect(find.text('1/2'), findsNothing);
    expect(find.text('0/2'), findsNothing);
  });

  testWidgets('Continue is gated on a selection', (tester) async {
    await _pumpQuiz(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('What are his hobbies?'), findsOneWidget);

    await tester.tap(find.text('He likes playing tennis.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Where do you live? I live __ London.'), findsOneWidget);
  });

  testWidgets('advancing clears the previous selection', (tester) async {
    await _pumpQuiz(tester);

    await tester.tap(find.text('He likes playing tennis.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(_isSelected(tester, 'in'), isFalse);
    expect(_isSelected(tester, 'on'), isFalse);
  });

  testWidgets('only one option is selected at a time', (tester) async {
    await _pumpQuiz(tester);

    await tester.tap(find.text('He tennis playing likes.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('He likes playing tennis.'));
    await tester.pumpAndSettle();

    expect(_isSelected(tester, 'He likes playing tennis.'), isTrue);
    expect(_isSelected(tester, 'He tennis playing likes.'), isFalse);
  });

  testWidgets('a long answer wraps instead of overflowing', (tester) async {
    await _pumpQuiz(tester);

    expect(tester.takeException(), isNull);

    // Taller than a single-line chip, so the text wrapped rather than clipped.
    final long = tester.getSize(
      find.ancestor(
        of: find.text(_longOption),
        matching: find.byType(AppOptionChip),
      ),
    );
    final short = tester.getSize(
      find.ancestor(
        of: find.text('He tennis playing likes.'),
        matching: find.byType(AppOptionChip),
      ),
    );
    expect(long.height, greaterThan(short.height));
  });
}
