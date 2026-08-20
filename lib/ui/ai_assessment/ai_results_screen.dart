import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/ui/ai_assessment/widget/assessment_summary_card.dart';
import 'package:student/ui/ai_assessment/widget/level_card.dart';
import 'package:student/ui/ai_assessment/widget/skill_breakdown_card.dart';
import 'package:student/ui/main/app_screen.dart';

class AiResultsScreen extends StatelessWidget {
  static const path = '/ai-results';

  const AiResultsScreen({super.key});

  /// Placeholder scores until the API returns a real breakdown; only the
  /// names come from the locale.
  static List<SkillBreakdownItem> _skills(AppLocalizations l10n) => [
    SkillBreakdownItem(
      name: l10n.aiSkillGrammar,
      percent: 86,
      color: const Color(0xFF18C96A),
    ),
    SkillBreakdownItem(
      name: l10n.aiSkillVocabulary,
      percent: 74,
      color: const Color(0xFF3B82F6),
    ),
    SkillBreakdownItem(
      name: l10n.aiSkillFluency,
      percent: 68,
      color: const Color(0xFFF59E0B),
    ),
    SkillBreakdownItem(
      name: l10n.aiSkillPronunciation,
      percent: 71,
      color: const Color(0xFF8B5CF6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    const LevelCard(
                      level: 'B2',
                      previousLevel: 'B1',
                      answersCount: 5,
                    ),
                    const SizedBox(height: 16),
                    SkillBreakdownCard(items: _skills(l10n)),
                    const SizedBox(height: 16),
                    AssessmentSummaryCard(summary: l10n.aiSummary),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.filled(
                        label: l10n.aiStartLearning,
                        fontSize: 16,
                        onTap: () => context.go(AppScreen.path),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 36, height: 36),
          Expanded(
            child: Text(
              AppLocalizations.of(context).aiResultsTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.go(AppScreen.path),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
