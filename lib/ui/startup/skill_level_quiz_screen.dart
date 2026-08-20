import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/startup/presentation/skill_quiz_controller.dart';
import 'package:student/core/startup/presentation/skill_quiz_result_controller.dart';
import 'package:student/core/user/domain/entity/student_level.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_gradient_background.dart';
import 'package:student/shared/widget/app_option_chip.dart';
import 'package:student/shared/widget/app_progress_header.dart';
import 'package:student/ui/auth/register_screen.dart';
import 'package:student/ui/startup/level_check_screen.dart';

class SkillLevelQuizScreen extends ConsumerStatefulWidget {
  static const path = '/skill_quiz';

  const SkillLevelQuizScreen({super.key});

  @override
  ConsumerState<SkillLevelQuizScreen> createState() =>
      _SkillLevelQuizScreenState();
}

class _SkillLevelQuizScreenState extends ConsumerState<SkillLevelQuizScreen> {
  int _questionIndex = 0;
  int? _selectedOption;

  /// Answers matching the question's `correct` value so far. Only the tally is
  /// kept — nothing here needs to say which ones were missed.
  int _correctCount = 0;

  void _onClose() {
    // The level check navigates here with `go`, so there may be nothing to pop.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(LevelCheckScreen.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(skillQuestionsController);

    if (questions.isEmpty) {
      return const Scaffold(
        body: AppGradientBackground(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final question = questions[_questionIndex];

    void onContinue() {
      final chosen = question.options[_selectedOption!];
      // The asset's `correct` holds the option's text, not its index, and is
      // authored by hand — so compare leniently.
      if (chosen.trim().toLowerCase() ==
          question.correct.trim().toLowerCase()) {
        _correctCount++;
      }

      if (_questionIndex < questions.length - 1) {
        setState(() {
          _questionIndex++;
          _selectedOption = null;
        });
        return;
      }

      ref
          .read(skillQuizResultProvider.notifier)
          .setLevel(
            StudentLevel.fromScore(
              correct: _correctCount,
              total: questions.length,
            ),
          );
      context.go(RegisterScreen.path);
    }

    return Scaffold(
      body: AppGradientBackground(
        child: Column(
          children: [
            AppProgressHeader(
              progress: (_questionIndex + 1) / questions.length,
              onClose: _onClose,
              closeColor: AppColors.deepGreen,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.question,
                      style: const TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    for (var i = 0; i < question.options.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.md),
                      // Full width rather than the survey's staggered pills —
                      // answers vary in length and read better aligned.
                      SizedBox(
                        width: double.infinity,
                        child: AppOptionChip(
                          label: question.options[i],
                          isSelected: _selectedOption == i,
                          maxLines: 3,
                          onTap: () => setState(() => _selectedOption = i),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            AppBottomActionBar(
              children: [
                AppButton.filled(
                  label: AppLocalizations.of(context).commonContinue,
                  onTap: _selectedOption != null ? onContinue : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
