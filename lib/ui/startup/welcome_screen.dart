import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/startup/survey_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const path = '/welcome';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    void onGotoSurveyClick() {
      context.push(SurveyScreen.path);
    }

    void onGotoLoginClick() {
      context.push(LoginScreen.path);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppSpacing.xl),
            Image.asset('assets/images/welcome.png', height: 250),
            SizedBox(height: AppSpacing.xl),
            Text(
              l10n.welcomeTitle,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                l10n.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.filled(
                      label: l10n.welcomeGetStarted,
                      onTap: onGotoSurveyClick,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.white(
                      label: l10n.welcomeSignIn,
                      onTap: onGotoLoginClick,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
