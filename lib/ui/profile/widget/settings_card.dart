import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/app/locale/locale_controller.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/notifications/presentation/push_messaging_service.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_confirm_sheet.dart';
import 'package:student/ui/auth/forgot_password_screen.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/profile/widget/language_sheet.dart';
import 'package:student/ui/profile/widget/profile_icons.dart';
import 'package:student/utils/messenger.dart';

const _ink = Color(0xFF15141A);
const _muted = Color(0xFF8A8C9C);
const _danger = Color(0xFFEF5350);
const _tile = Color(0xFFF2F4F9);

/// The profile's two grouped lists: Settings (app language, change password)
/// and Account (log out, delete account).
class SettingsCard extends ConsumerWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Falls back to whatever the device resolved to, which is what the app is
    // actually running in until the student picks something.
    final language =
        ref.watch(localeControllerProvider) ??
        AppLanguage.fromLocale(Localizations.localeOf(context)) ??
        AppLanguage.uz;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupLabel(l10n.profileSettings),
        _Group(
          rows: [
            _SettingRow(
              icon: ProfileIcons.locale(size: 18),
              label: l10n.profileAppLanguage,
              value: language.label,
              onTap: () => showLanguageSheet(context, language),
            ),
            _SettingRow(
              icon: SvgPicture.asset('assets/icons/locked.svg', width: 18),
              label: l10n.profileChangePassword,
              // Reuses the recovery flow — it verifies by OTP and sets a new
              // password, which is what changing one means here.
              onTap: () => context.push(ForgotPasswordScreen.path),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _GroupLabel(l10n.profileAccount),
        _Group(
          rows: [
            _SettingRow(
              icon: SvgPicture.asset('assets/icons/logout.svg', width: 18),
              label: l10n.settingsLogOut,
              onTap: () => _confirmLogout(context, ref),
            ),
            _SettingRow(
              icon: const Icon(Icons.delete_rounded, size: 18, color: _danger),
              iconFill: const Color(0xFFFDECEC),
              label: l10n.settingsDeleteAccount,
              labelColor: _danger,
              showChevron: false,
              onTap: () => _confirmDeleteAccount(context),
            ),
          ],
        ),
      ],
    );
  }

  /// Asks first; on yes, files the deletion request. Nothing is signed out
  /// or cleared — the account stays usable until the request is actioned —
  /// so the outcome is just a confirmation message.
  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      icon: SvgPicture.asset('assets/icons/trash.svg', width: 24),
      title: l10n.settingsDeleteConfirm,
      message: l10n.settingsDeleteBody,
      confirmLabel: l10n.settingsDeleteAction,
    );
    if (!confirmed || !context.mounted) return;
    showSuccessMessage(
      context,
      l10n.settingsDeleteRequestedTitle,
      detail: l10n.settingsDeleteRequestedBody,
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      icon: SvgPicture.asset('assets/icons/logout.svg', width: 24),
      title: l10n.settingsLogOutConfirm,
      message: l10n.settingsLogOutBody,
      confirmLabel: l10n.settingsLogOutAction,
    );
    if (!confirmed) return;
    // Unregisters the device for push. Has to go first — it is an
    // authenticated call, and clearing the tokens would strand the session
    // row on the server, still receiving this student's notifications.
    await ref.read(pushMessagingProvider).signOut();
    await ref.read(tokenStorageProvider).clearAll();
    ref.read(currentUserProvider.notifier).state = null;
    if (context.mounted) context.go(LoginScreen.path);
  }
}

/// A grey all-caps caption above a group.
class _GroupLabel extends StatelessWidget {
  final String text;

  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFA5A6B9),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// White rounded card of rows with thin dividers between them.
class _Group extends StatelessWidget {
  final List<Widget> rows;

  const _Group({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFEFEFF3)),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final Widget icon;
  final Color iconFill;
  final String label;
  final Color labelColor;
  final String? value;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconFill = _tile,
    this.labelColor = _ink,
    this.value,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconFill,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                value,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (showChevron) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: Color(0xFFA5A6B9),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
