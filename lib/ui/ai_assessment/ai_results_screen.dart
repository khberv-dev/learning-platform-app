import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/ui/ai_assessment/widget/assessment_summary_card.dart';
import 'package:student/ui/ai_assessment/widget/level_card.dart';
import 'package:student/ui/ai_assessment/widget/skill_breakdown_card.dart';
import 'package:student/ui/main/app_screen.dart';

class AiResultsScreen extends StatelessWidget {
  static const path = '/ai-results';

  const AiResultsScreen({super.key});

  static const _skills = [
    SkillBreakdownItem(name: 'Grammar', percent: 86, color: Color(0xFF18C96A)),
    SkillBreakdownItem(
      name: 'Vocabulary',
      percent: 74,
      color: Color(0xFF3B82F6),
    ),
    SkillBreakdownItem(name: 'Fluency', percent: 68, color: Color(0xFFF59E0B)),
    SkillBreakdownItem(
      name: 'Pronunciation',
      percent: 71,
      color: Color(0xFF8B5CF6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                    const SkillBreakdownCard(items: _skills),
                    const SizedBox(height: 16),
                    const AssessmentSummaryCard(
                      summary:
                          'You show strong B2-level grammar and professional '
                          'vocabulary. Focus on fluency and pronunciation to '
                          'reach C1.',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF18C96A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => context.go(AppScreen.path),
                        child: const Text(
                          'Start Personalized Learning',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
          const Expanded(
            child: Text(
              'Skill Results',
              textAlign: TextAlign.center,
              style: TextStyle(
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
