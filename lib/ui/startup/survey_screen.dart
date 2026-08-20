import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/startup/domain/model/survey_query.dart';
import 'package:student/core/startup/domain/model/survey_query_option.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_gradient_background.dart';
import 'package:student/shared/widget/app_option_chip.dart';
import 'package:student/shared/widget/app_progress_header.dart';
import 'package:student/ui/startup/level_check_screen.dart';
import 'package:student/ui/startup/onboarding_screen.dart';

/// Built per-build rather than held as a `const`, because the wording comes
/// from the current locale. The emoji don't.
List<SurveyQuery> _surveyQueries(AppLocalizations l10n) => [
  SurveyQuery(
    title: l10n.surveyReasonTitle,
    description: l10n.surveyReasonDescription,
    options: [
      SurveyQueryOption(text: l10n.surveyReasonCareer, emoji: '💼'),
      SurveyQueryOption(text: l10n.surveyReasonTravel, emoji: '🌍'),
      SurveyQueryOption(text: l10n.surveyReasonAcademic, emoji: '📚'),
      SurveyQueryOption(text: l10n.surveyReasonPersonal, emoji: '💝'),
      SurveyQueryOption(text: l10n.surveyReasonImmigration, emoji: '👥'),
    ],
  ),
  SurveyQuery(
    title: l10n.surveyTimeTitle,
    description: l10n.surveyTimeDescription,
    options: [
      SurveyQueryOption(text: l10n.surveyTime5, emoji: '⏱️'),
      SurveyQueryOption(text: l10n.surveyTime15, emoji: '☕'),
      SurveyQueryOption(text: l10n.surveyTime30, emoji: '📖'),
      SurveyQueryOption(text: l10n.surveyTime60, emoji: '🔥'),
    ],
  ),
];

/// How many queries [_surveyQueries] returns, needed outside a build where
/// there is no [AppLocalizations] to hand.
const _surveyQueryCount = 2;

class SurveyScreen extends StatefulWidget {
  static const path = '/survey';

  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int _queryIndex = 0;

  /// Answers so far, keyed by question index — not by the question itself,
  /// whose wording changes with the locale.
  final Map<int, Set<int>> _selected = {};

  Set<int> get _currentSelection => _selected[_queryIndex] ?? const {};

  void _onOptionTap(SurveyQuery query, int index) {
    setState(() {
      final current = {..._currentSelection};
      if (query.allowsMultiple) {
        if (!current.remove(index)) current.add(index);
      } else {
        current
          ..clear()
          ..add(index);
      }
      _selected[_queryIndex] = current;
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
    if (_queryIndex < _surveyQueryCount - 1) {
      setState(() => _queryIndex++);
    } else {
      context.go(LevelCheckScreen.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _surveyQueries(l10n)[_queryIndex];

    return Scaffold(
      body: AppGradientBackground(
        child: Column(
          children: [
            AppProgressHeader(
              // The level check that follows is one more step of the same
              // intake, so the bar shouldn't read as full before it.
              progress: (_queryIndex + 1) / (_surveyQueryCount + 1),
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
                      query.title,
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
                      query.description,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _OptionStagger(
                      options: query.options,
                      selected: _currentSelection,
                      onTap: (index) => _onOptionTap(query, index),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomActionBar(
              children: [
                AppButton.filled(
                  label: l10n.commonResume,
                  onTap: _currentSelection.isEmpty ? null : _onNext,
                ),
                AppButton.outlined(label: l10n.commonBack, onTap: _onBack),
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
