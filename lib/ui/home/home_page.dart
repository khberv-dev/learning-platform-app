import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/ui/home/widget/ai_test_card.dart';
import 'package:student/ui/home/widget/continue_learning_card.dart';
import 'package:student/ui/home/widget/home_topbar.dart';
import 'package:student/ui/home/widget/live_session_card.dart';
import 'package:student/ui/home/widget/speaking_partner_card.dart';
import 'package:student/ui/home/widget/stats_row.dart';
import 'package:student/ui/home/widget/upcoming_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: AppSpacing.xxl,
        bottom: AppSpacing.xl,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeTopbar(),
          SizedBox(height: AppSpacing.lg),
          StatsRow(),
          SizedBox(height: AppSpacing.lg),
          ContinueLearningCard(),
          SizedBox(height: AppSpacing.lg),
          AiTestCard(),
          SizedBox(height: AppSpacing.lg),
          SpeakingPartnerCard(),
          SizedBox(height: AppSpacing.lg),
          LiveSessionCard(),
          SizedBox(height: AppSpacing.lg),
          UpcomingSection(),
        ],
      ),
    );
  }
}
