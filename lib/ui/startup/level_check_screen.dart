import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/startup/presentation/skill_quiz_result_controller.dart';
import 'package:student/core/user/domain/entity/student_level.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_gradient_background.dart';
import 'package:student/shared/widget/app_option_chip.dart';
import 'package:student/shared/widget/app_progress_header.dart';
import 'package:student/ui/auth/register_screen.dart';
import 'package:student/ui/startup/onboarding_screen.dart';
import 'package:student/ui/startup/skill_level_quiz_screen.dart';
import 'package:student/ui/startup/survey_screen.dart';

/// Asks whether the student has any English at all, and sends only those who
/// do on to the placement quiz.
///
/// A complete beginner has nothing to place: the quiz is multiple choice, so
/// guessing through it scores around chance level, which
/// [StudentLevel.fromScore] reads as [StudentLevel.a1] anyway. Skipping it
/// spares them a dozen questions to reach the level they already said they
/// were at.
class LevelCheckScreen extends ConsumerStatefulWidget {
  static const path = '/level_check';

  const LevelCheckScreen({super.key});

  @override
  ConsumerState<LevelCheckScreen> createState() => _LevelCheckScreenState();
}

class _LevelCheckScreenState extends ConsumerState<LevelCheckScreen> {
  /// Null until an answer is picked, which is what gates Resume.
  bool? _hasEnglish;

  void _onBack() {
    // The survey navigates here with `go`, so there is usually nothing to pop.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(SurveyScreen.path);
    }
  }

  void _onResume() {
    if (_hasEnglish!) {
      context.go(SkillLevelQuizScreen.path);
      return;
    }

    // Recorded rather than left to the API's default, so that a level from an
    // earlier run through the quiz can't follow the student to sign-up after
    // they have said they are starting from scratch.
    ref.read(skillQuizResultProvider.notifier).setLevel(StudentLevel.a1);
    context.go(RegisterScreen.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Column(
          children: [
            AppProgressHeader(
              // The last step of the intake: the quiz that may follow starts
              // its own bar over.
              progress: 1,
              // `go`, not `pop` — closing the flow should land on onboarding
              // regardless of how the user got here.
              onClose: () => context.go(OnboardingScreen.path),
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
                    const Text(
                      'Do you already know some English?',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.22,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'If you have studied before, a short test places you at '
                      'the right level',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Full width rather than the survey's staggered pills —
                    // these answers are sentences, and read better aligned.
                    _Answer(
                      label: 'Yes, I have studied some',
                      emoji: '🗣️',
                      isSelected: _hasEnglish == true,
                      onTap: () => setState(() => _hasEnglish = true),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Answer(
                      label: 'No, I am starting from zero',
                      emoji: '🌱',
                      isSelected: _hasEnglish == false,
                      onTap: () => setState(() => _hasEnglish = false),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomActionBar(
              children: [
                AppButton.filled(
                  label: 'Resume',
                  onTap: _hasEnglish == null ? null : _onResume,
                ),
                AppButton.outlined(label: 'Back', onTap: _onBack),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Answer extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _Answer({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppOptionChip(
        label: label,
        leading: Text(emoji),
        isSelected: isSelected,
        maxLines: 2,
        onTap: onTap,
      ),
    );
  }
}
