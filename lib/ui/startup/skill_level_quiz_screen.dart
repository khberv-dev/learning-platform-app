import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/startup/presentation/skill_quiz_controller.dart';
import 'package:student/ui/auth/register_screen.dart';
import 'package:student/ui/startup/widget/quiz_option_select.dart';

class SkillLevelQuizScreen extends ConsumerStatefulWidget {
  static const path = '/skill_quiz';

  const SkillLevelQuizScreen({super.key});

  @override
  ConsumerState<SkillLevelQuizScreen> createState() =>
      _SkillLevelQuizScreenState();
}

class _SkillLevelQuizScreenState extends ConsumerState<SkillLevelQuizScreen> {
  int currentQuestionIndex = 0;
  int? currentQuestionSelectedOptionIndex;

  @override
  Widget build(BuildContext context) {
    final skillQuestions = ref.watch(skillQuestionsController);

    void onQuestionOptionClick(int index) {
      setState(() {
        currentQuestionSelectedOptionIndex = index;
      });
    }

    void onContinueClick() {
      if (currentQuestionIndex < skillQuestions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          currentQuestionSelectedOptionIndex = null;
        });
      } else {
        context.go(RegisterScreen.path);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: skillQuestions.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value:
                                  (currentQuestionIndex + 1) /
                                  skillQuestions.length,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Text(
                            '$currentQuestionIndex/${skillQuestions.length}',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        skillQuestions[currentQuestionIndex].question,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxl),
                      QuizOptionSelect(
                        options: skillQuestions[currentQuestionIndex].options,
                        current: currentQuestionSelectedOptionIndex,
                        onItemClick: onQuestionOptionClick,
                      ),
                      SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: currentQuestionSelectedOptionIndex != null
                              ? onContinueClick
                              : null,
                          child: Text("Continue"),
                        ),
                      ),
                    ],
                  ),
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
