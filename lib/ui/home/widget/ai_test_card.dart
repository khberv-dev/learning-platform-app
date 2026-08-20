import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/ai_assessment/ai_assessment_screen.dart';
import 'package:student/ui/home/widget/home_promo_card.dart';

class AiTestCard extends StatelessWidget {
  const AiTestCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return HomePromoCard(
      background: AppColors.promoBlue,
      title: l10n.homeAiTestTitle,
      subtitle: l10n.homeAiTestBody,
      buttonLabel: l10n.homeAiTestButton,
      imagePath: 'assets/images/ai_assistant_puppet.png',
      onTap: () => context.push(AiAssessmentScreen.path),
    );
  }
}
