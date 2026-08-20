import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/home/widget/home_promo_card.dart';
import 'package:student/ui/p2p/p2p_matchmaking_screen.dart';

class SpeakingPartnerCard extends StatelessWidget {
  const SpeakingPartnerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return HomePromoCard(
      background: Theme.of(context).colorScheme.primary,
      // The brand green is bright enough that automatic contrast picks black;
      // the design wants white on it.
      foreground: Colors.white,
      title: l10n.homeSpeakingTitle,
      subtitle: l10n.homeSpeakingBody,
      // Blue so the action still reads against the green card.
      buttonLabel: l10n.homeSpeakingButton,
      buttonColor: AppColors.promoBlue,
      imagePath: 'assets/images/speaking_partner_puppet.png',
      onTap: () => context.push(P2pMatchmakingScreen.path),
    );
  }
}
