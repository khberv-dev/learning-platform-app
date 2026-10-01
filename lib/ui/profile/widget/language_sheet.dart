import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/app/locale/locale_controller.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/profile/widget/profile_icons.dart';

const _ink = Color(0xFF15141A);
const _muted = Color(0xFF717384);
const _green = Color(0xFF78C93C);
const _rowFill = Color(0xFFF2F4F9);
const _selectedFill = Color(0xFFEDF9DB);

/// Opens the app-language sheet, starting on [current]. The choice only
/// takes effect on Save; closing the sheet any other way changes nothing.
Future<void> showLanguageSheet(BuildContext context, AppLanguage current) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => LanguageSheet(initial: current),
  );
}

class LanguageSheet extends ConsumerStatefulWidget {
  final AppLanguage initial;

  const LanguageSheet({super.key, required this.initial});

  @override
  ConsumerState<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends ConsumerState<LanguageSheet> {
  late AppLanguage _selected = widget.initial;

  void _save() {
    // Applies straight away — the whole app rebuilds in the new language
    // behind the closing sheet.
    ref.read(localeControllerProvider.notifier).select(_selected);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The artwork is the whole badge — a blue disc with the glyph.
            Center(child: ProfileIcons.locale(size: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.profileAppLanguage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.profileLanguageHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final language in AppLanguage.values) ...[
              _LanguageOption(
                language: language,
                selected: language == _selected,
                onTap: () => setState(() => _selected = language),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppFlatPillButton(
              label: l10n.commonSave,
              background: _green,
              foreground: Colors.white,
              onTap: _save,
              height: 48,
              fontSize: 15,
            ),
          ],
        ),
      ),
    );
  }
}

/// A stadium row: a white disc with the flag, the language in its own
/// name, and a radio — green with a tick, on a tinted, outlined row, once
/// chosen.
class _LanguageOption extends StatelessWidget {
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
      side: selected
          ? const BorderSide(color: _green, width: 2)
          : BorderSide.none,
    );

    return Semantics(
      button: true,
      selected: selected,
      label: language.label,
      excludeSemantics: true,
      child: Material(
        key: ValueKey('language-${language.code}'),
        color: selected ? _selectedFill : _rowFill,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 18, 6),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: Image.asset(
                      language.flagAsset,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    language.label,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF66D46F) : null,
                    shape: BoxShape.circle,
                    border: selected
                        ? null
                        : Border.all(
                            color: const Color(0xFFD5D7DA),
                            width: 1.5,
                          ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Color(0xFF395363),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
