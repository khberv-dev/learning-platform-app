import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/startup/presentation/skill_quiz_controller.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_gradient_background.dart';
import 'package:student/shared/widget/app_option_chip.dart';
import 'package:student/shared/widget/app_progress_header.dart';
import 'package:student/ui/auth/register_screen.dart';
import 'package:student/ui/startup/survey_screen.dart';

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

  void _onClose() {
    // The survey navigates here with `go`, so there may be nothing to pop.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(SurveyScreen.path);
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
      if (_questionIndex < questions.length - 1) {
        setState(() {
          _questionIndex++;
          _selectedOption = null;
        });
      } else {
        context.go(RegisterScreen.path);
      }
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
                  label: 'Continue',
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
