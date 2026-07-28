import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/startup/domain/model/survey_query.dart';
import 'package:student/core/startup/domain/model/survey_query_option.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_gradient_background.dart';
import 'package:student/shared/widget/app_option_chip.dart';
import 'package:student/shared/widget/app_progress_header.dart';
import 'package:student/ui/startup/onboarding_screen.dart';
import 'package:student/ui/startup/skill_level_quiz_screen.dart';

const _surveyQueries = [
  SurveyQuery(
    title: 'Why are you learning English?',
    description: 'Choose the one that fits best',
    options: [
      SurveyQueryOption(text: 'Career Growth', emoji: '💼'),
      SurveyQueryOption(text: 'Travel & Adventure', emoji: '🌍'),
      SurveyQueryOption(text: 'Academic Studies', emoji: '📚'),
      SurveyQueryOption(text: 'Personal Interest', emoji: '💝'),
      SurveyQueryOption(text: 'Immigration', emoji: '👥'),
    ],
  ),
  SurveyQuery(
    title: 'How much time can you spend daily?',
    description: "We'll build a schedule that fits your lifestyle",
    options: [
      SurveyQueryOption(text: '5 minutes', emoji: '⏱️'),
      SurveyQueryOption(text: '15 minutes', emoji: '☕'),
      SurveyQueryOption(text: '30 minutes', emoji: '📖'),
      SurveyQueryOption(text: '1+ hour', emoji: '🔥'),
    ],
  ),
];

class SurveyScreen extends StatefulWidget {
  static const path = '/survey';

  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int _queryIndex = 0;
  final Map<SurveyQuery, Set<int>> _selected = {};

  SurveyQuery get _query => _surveyQueries[_queryIndex];

  Set<int> get _currentSelection => _selected[_query] ?? const {};

  void _onOptionTap(int index) {
    setState(() {
      final current = {..._currentSelection};
      if (_query.allowsMultiple) {
        if (!current.remove(index)) current.add(index);
      } else {
        current
          ..clear()
          ..add(index);
      }
      _selected[_query] = current;
    });
  }

  void _onBack() {
    if (_queryIndex == 0) {
      context.pop();
    } else {
      setState(() => _queryIndex--);
    }
  }

  void _onNext() {
    if (_queryIndex < _surveyQueries.length - 1) {
      setState(() => _queryIndex++);
    } else {
      context.go(SkillLevelQuizScreen.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Column(
          children: [
            AppProgressHeader(
              progress: (_queryIndex + 1) / _surveyQueries.length,
              // `go`, not `pop` — closing the survey should land on
              // onboarding regardless of how the user got here.
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
                    Text(
                      _query.title,
                      style: const TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.22,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _query.description,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _OptionStagger(
                      options: _query.options,
                      selected: _currentSelection,
                      onTap: _onOptionTap,
                    ),
                  ],
                ),
              ),
            ),
            AppBottomActionBar(
              children: [
                AppButton.filled(
                  label: 'Resume',
                  onTap: _currentSelection.isEmpty ? null : _onNext,
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

/// Chips sized to their content, alternating left- and right-aligned so the
/// column zig-zags the way the design does.
class _OptionStagger extends StatelessWidget {
  final List<SurveyQueryOption> options;
  final Set<int> selected;
  final ValueChanged<int> onTap;

  const _OptionStagger({
    required this.options,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          Align(
            alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
            child: AppOptionChip(
              label: options[i].text,
              leading: Text(options[i].emoji),
              isSelected: selected.contains(i),
              onTap: () => onTap(i),
            ),
          ),
        ],
      ],
    );
  }
}
