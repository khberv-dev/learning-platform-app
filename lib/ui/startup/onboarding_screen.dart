import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/startup/survey_screen.dart';

/// New brand accent introduced with the redesign — lighter/more lime than the
/// old theme green, used only where a mockup specifically calls for it.
const _brandGreen = Color(0xFF78C93C);

/// First screen after picking a language: the pitch, then a fork into a
/// fresh placement-quiz start or straight to login.
///
/// Same pattern as [LanguageScreen] — the illustration fills all the space
/// above a fixed-height bottom card, with no scrolling anywhere. Expanded
/// only works as a direct Column/Row child, not inside a Stack, so this is a
/// Column, not a Stack+Align.
class OnboardingScreen extends StatelessWidget {
  static const path = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Pale sky behind the status bar, so the system icons need to be dark.
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F1F3),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // Fills all the space the bottom card leaves it, cropping
              // rather than scrolling — anchored top so an overflow trims
              // off the bottom of the illustration, never the top.
              Expanded(
                child: ClipRect(
                  child: Image.asset(
                    'assets/images/bg_welcome.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              Align(
                alignment: AlignmentGeometry.bottomEnd,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _Heading(),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.onboardingSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppFlatPillButton(
                        label: l10n.onboardingFreshStart,
                        background: _brandGreen,
                        foreground: Colors.white,
                        onTap: () => context.push(SurveyScreen.path),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppFlatPillButton(
                        label: l10n.onboardingResume,
                        background: Colors.white,
                        foreground: const Color(0xFF111827),
                        onTap: () => context.push(LoginScreen.path),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
            style: const TextStyle(color: _brandGreen),
          ),
          TextSpan(text: l10n.onboardingHeadlineTail),
        ],
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.22,
        letterSpacing: -0.5,
      ),
    );
  }
}
