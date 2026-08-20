import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/app/locale/app_language.dart';
import 'package:student/app/locale/locale_controller.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/notifications/presentation/push_messaging_service.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/url_launcher.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/profile/widget/profile_pill.dart';

const _privacyPolicyUrl = 'https://i-teach.uz/web/privacy_policy.html';

/// Dark panel of white pill rows, running to the bottom of the page.
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

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.librarySurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        children: [
          ProfileSettingRow(
            label: l10n.languageSettingsTitle,
            trailing: ProfileSettingValue(
              value: language.label,
              showChevron: true,
            ),
            onTap: () => _showLanguagePicker(context, ref, language),
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileSettingRow(
            label: l10n.settingsPrivacyPolicy,
            trailing: const ProfileSettingValue(showChevron: true),
            onTap: () =>
                ref.read(urlLauncherProvider)(Uri.parse(_privacyPolicyUrl)),
          ),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) => ProfileSettingRow(
              label: l10n.settingsAppVersion,
              trailing: ProfileSettingValue(
                value: snap.data == null ? '—' : 'v${snap.data!.version}',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileSettingRow(
            label: l10n.settingsLogOut,
            labelColor: const Color(0xffef4444),
            onTap: () => _confirmLogout(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileSettingRow(
            label: l10n.settingsDeleteAccount,
            labelColor: const Color(0xffef4444),
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  /// Step 1: make the student say yes before anything happens. Answering no
  /// just closes it.
  void _confirmDeleteAccount(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          l10n.settingsDeleteAccount,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(l10n.settingsDeleteConfirm),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: Text(l10n.commonNo),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDeletionRequested(context);
            },
            child: Text(
              l10n.commonYes,
              style: const TextStyle(color: Color(0xffef4444)),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 2: acknowledge the request. Nothing is signed out or cleared here —
  /// the account stays usable until the request is actioned.
  void _showDeletionRequested(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          l10n.settingsDeleteRequestedTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(l10n.settingsDeleteRequestedBody),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: Text(l10n.commonOk),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          l10n.settingsLogOut,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(l10n.settingsLogOutConfirm),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Unregisters the device for push. Has to go first — it is an
              // authenticated call, and clearing the tokens would strand the
              // session row on the server, still receiving this student's
              // notifications.
              await ref.read(pushMessagingProvider).signOut();
              await ref.read(tokenStorageProvider).clearAll();
              ref.read(currentUserProvider.notifier).state = null;
              if (context.mounted) context.go(LoginScreen.path);
            },
            child: Text(
              l10n.settingsLogOut,
              style: const TextStyle(color: Color(0xffef4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    AppLanguage current,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          AppLocalizations.of(ctx).languageSettingsTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((language) {
            final selected = language == current;
            return InkWell(
              onTap: () {
                // Applies straight away — the whole app rebuilds in the new
                // language behind the closing dialog.
                ref.read(localeControllerProvider.notifier).select(language);
                Navigator.of(ctx).pop();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${language.flag}  ${language.label}',
                      style: TextStyle(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black,
                        fontSize: 16,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (selected)
                      Icon(
                        Icons.check_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
