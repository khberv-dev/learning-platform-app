import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/startup/survey_screen.dart';

/// New brand accent introduced with the redesign — lighter/more lime than the
/// old theme green, used only where a mockup specifically calls for it.
const _brandGreen = Color(0xFF78C93C);

/// First screen after picking a language: the pitch, then a fork into a
/// fresh placement-quiz start or straight to login.
///
/// Same pattern as [LanguageScreen] — the illustration fills all the space
/// above a fixed-height bottom card, with no scrolling anywhere.
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
              // rather than scrolling — anchored top so an overflow trims off
              // the bottom of the illustration, never the top.
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
                      _FlatPillButton(
                        label: l10n.onboardingFreshStart,
                        background: _brandGreen,
                        foreground: Colors.white,
                        onTap: () => context.push(SurveyScreen.path),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FlatPillButton(
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

/// The redesign's button: a flat pill with a soft drop shadow, no gloss or
/// 3D press-sink like the old shared `AppButton`. Screen-local for now — see
/// `AppButton`'s doc comment for why the old style stays put elsewhere.
class _FlatPillButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _FlatPillButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.round);

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: background,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
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
