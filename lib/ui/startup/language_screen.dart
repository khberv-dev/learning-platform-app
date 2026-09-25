import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/app/locale/locale_controller.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/startup/onboarding_screen.dart';

/// Row order for this screen only — Russian, then Uzbek, then English, per
/// the redesign's exact mockup. Distinct from [AppLanguage.values], which
/// stays Uzbek-first since that order still drives the device-locale
/// fallback elsewhere (see [AppLanguage]).
const _displayOrder = [AppLanguage.ru, AppLanguage.uz, AppLanguage.en];

/// Asks which language to run in, once, on the first launch.
///
/// The splash screen sends the student here when nothing is stored yet, and
/// passes on where they were headed as `next` so the choice costs them no
/// ground: they carry on to onboarding, the app or the login screen exactly as
/// they would have. Tapping an option both commits it and continues — there is
/// no separate confirmation step, since a language picker is the one screen a
/// student may not be able to read well enough to want a preview of first.
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
    // Only ever used to pick which language the headline itself opens in, so
    // it reads in something the student is likely to understand.
    _selected ??=
        AppLanguage.fromLocale(Localizations.localeOf(context)) ??
        AppLanguage.uz;
  }

  Future<void> _select(AppLanguage language) async {
    await ref.read(localeControllerProvider.notifier).select(language);
    if (!mounted) return;
    context.go(widget.next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Flat light grey, matching the mockup exactly — this page has no
      // gradient.
      backgroundColor: const Color(0xFFF1F1F3),
      body: Localizations.override(
        context: context,
        locale: _selected!.locale,
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);

            return SafeArea(
              top: false,
              // Expanded only works as a direct Column/Row child, not inside
              // a Stack — this is a Column so the image can claim all the
              // space above the fixed-height card below it, with no scroll.
              child: Column(
                children: [
                  // Fills all the space the bottom card leaves it, cropping
                  // rather than scrolling — anchored top so an overflow trims
                  // off the bottom of the illustration, never the top.
                  Expanded(
                    child: ClipRect(
                      child: Image.asset(
                        'assets/images/bg_select_language.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.languageTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF111827),
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
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        for (final language in _displayOrder) ...[
                          if (language != _displayOrder.first)
                            const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: _LanguageRow(
                              language: language,
                              onTap: () => _select(language),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final AppLanguage language;
  final VoidCallback onTap;

  const _LanguageRow({required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Fully round — a stadium shape regardless of the row's height, per the
    // redesign's "select-language button radius must be circular" rule.
    final radius = BorderRadius.circular(AppRadius.round);

    return Semantics(
      button: true,
      label: language.label,
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: Image.asset(
                      language.flagAsset,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    language.label,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF111827),
                  size: 24,
                ),
              ],
            ),
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
