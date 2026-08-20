import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/app/locale/locale_controller.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_gradient_background.dart';
import 'package:student/shared/widget/app_option_chip.dart';
import 'package:student/ui/startup/onboarding_screen.dart';

/// Asks which language to run in, once, on the first launch.
///
/// The splash screen sends the student here when nothing is stored yet, and
/// passes on where they were headed as `next` so the choice costs them no
/// ground: they carry on to onboarding, the app or the login screen exactly as
/// they would have.
class LanguageScreen extends ConsumerStatefulWidget {
  static const path = '/language';

  /// Where to continue once a language is picked.
  final String next;

  const LanguageScreen({super.key, required this.next});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  AppLanguage? _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start on whatever the device resolved to, so Continue is never a dead
    // button and the screen opens in a language the student likely reads.
    _selected ??=
        AppLanguage.fromLocale(Localizations.localeOf(context)) ??
        AppLanguage.uz;
  }

  Future<void> _onContinue() async {
    // Stored only now: tapping through the options is a preview, and a student
    // who never reaches this button has not chosen anything yet.
    await ref.read(localeControllerProvider.notifier).select(_selected!);
    if (!mounted) return;
    context.go(widget.next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        // The page previews the highlighted language as it is tapped, before
        // anything is committed — the one screen where the student cannot read
        // their way out of a wrong guess.
        child: Localizations.override(
          context: context,
          locale: _selected!.locale,
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);

              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/select_language_puppet.png',
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              l10n.languageTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.deepGreen,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.22,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.languageSubtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            for (final language in AppLanguage.values) ...[
                              if (language != AppLanguage.values.first)
                                const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: AppOptionChip(
                                  label: language.label,
                                  leading: Text(language.flag),
                                  isSelected: _selected == language,
                                  onTap: () =>
                                      setState(() => _selected = language),
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                    AppBottomActionBar(
                      children: [
                        AppButton.filled(
                          label: l10n.languageContinue,
                          onTap: _onContinue,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Where the splash screen sends someone who has no language stored, keeping
/// the destination it had already worked out.
String languageRouteFor(String next) =>
    '${LanguageScreen.path}?next=${Uri.encodeComponent(next)}';

/// Fallback destination when the route is opened without a `next`.
const languageDefaultNext = OnboardingScreen.path;
