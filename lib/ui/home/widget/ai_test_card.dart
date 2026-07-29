import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/ui/ai_assessment/ai_assessment_screen.dart';
import 'package:student/ui/home/widget/home_promo_card.dart';

class AiTestCard extends StatelessWidget {
  const AiTestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePromoCard(
      background: AppColors.promoBlue,
      title: 'Test your skills with AI',
      subtitle:
          'Speak naturally and let AI evaluate your level — get a full '
          'skill report in minutes',
      buttonLabel: 'Start test',
      imagePath: 'assets/images/ai_assistant_puppet.png',
      onTap: () => context.push(AiAssessmentScreen.path),
    );
  }
}
