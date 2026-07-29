import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/ui/home/widget/home_promo_card.dart';
import 'package:student/ui/p2p/p2p_matchmaking_screen.dart';

class SpeakingPartnerCard extends StatelessWidget {
  const SpeakingPartnerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePromoCard(
      background: Theme.of(context).colorScheme.primary,
      // The brand green is bright enough that automatic contrast picks black;
      // the design wants white on it.
      foreground: Colors.white,
      title: 'Find a speaking partner',
      subtitle:
          'Get matched with a real person at your level. Practice '
          'conversations that matter',
      // Blue so the action still reads against the green card.
      buttonLabel: 'Find partner',
      buttonColor: AppColors.promoBlue,
      imagePath: 'assets/images/speaking_partner_puppet.png',
      onTap: () => context.push(P2pMatchmakingScreen.path),
    );
  }
}
