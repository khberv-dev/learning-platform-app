import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/startup/survey_screen.dart';

class OnboardingScreen extends StatelessWidget {
  static const path = '/onboarding';

  /// onboarding.png is 441x638.
  static const _artworkAspect = 638 / 441;

  /// Where the artwork's top edge sits, as a share of screen height.
  ///
  /// The artwork is drawn at its natural aspect across the full width — that's
  /// what keeps the clouds at both edges instead of cropping them — and pushed
  /// down so the mascot's head (11.8% into the artwork) lands ~25% down the
  /// screen, matching the design. The sky above it is [AppColors.onboardingSky].
  static const _artworkTopFactor = 0.17;

  /// Share of the artwork that must stay above the card, so the podiums the
  /// mascot stands on aren't swallowed by it on shorter screens.
  static const _minArtworkVisible = 0.9;

  /// Intrinsic height of [_ActionCard] excluding the bottom safe-area inset.
  static const _cardHeight =
      AppSpacing.lg * 2 +
      AppSpacing.md +
      (AppButton.defaultHeight + AppButton.defaultDepth) * 2;

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final artworkHeight = screenSize.width * _artworkAspect;
    final cardTop =
        screenSize.height - _cardHeight - MediaQuery.paddingOf(context).bottom;

    // Sit the artwork 17% down as the design does, but never so far down that
    // the card eats its bottom — short, wide screens pull it back up.
    final artworkTop = math.min(
      screenSize.height * _artworkTopFactor,
      math.max(0.0, cardTop - artworkHeight * _minArtworkVisible),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Pale sky behind the status bar, so the system icons need to be dark.
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.onboardingSky,
        body: Stack(
          children: [
            Positioned(
              top: artworkTop,
              left: 0,
              right: 0,
              height: artworkHeight,
              // The PNG is feathered to semi-transparent in its outer pixels;
              // overscale slightly and clip so those never show as a pale
              // fringe against the background.
              child: ClipRect(
                child: Transform.scale(
                  scale: 1.04,
                  child: Image.asset(
                    'assets/images/onboarding.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // On a tall screen this sits on flat sky and is invisible; on a
            // short one, where the clamp above pulls the mascot up level with
            // the heading, it fades the artwork back to sky behind the text.
            Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                widthFactor: 1,
                heightFactor: 0.32,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.onboardingSky,
                        AppColors.onboardingSky.withAlpha(0),
                      ],
                      stops: const [0.45, 1],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  0,
                ),
                child: const Align(
                  alignment: Alignment.topLeft,
                  child: _Heading(),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: _ActionCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Split into three so the middle word keeps its accent colour. Word order
    // differs by language, which is why the lead can be empty.
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: l10n.onboardingHeadlineLead),
          TextSpan(
            text: l10n.onboardingHeadlineHighlight,
            style: const TextStyle(color: AppColors.deepGreen),
          ),
          TextSpan(text: l10n.onboardingHeadlineTail),
        ],
      ),
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.3,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    void onFreshStartClick() => context.push(SurveyScreen.path);
    void onResumeClick() => context.push(LoginScreen.path);

    return AppBottomActionBar(
      children: [
        AppButton.filled(
          label: l10n.onboardingFreshStart,
          onTap: onFreshStartClick,
        ),
        AppButton.outlined(label: l10n.onboardingResume, onTap: onResumeClick),
      ],
    );
  }
}
