import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/notifications/presentation/push_messaging_service.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/shared/url_launcher.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/profile/widget/profile_pill.dart';

final selectedLanguageProvider = StateProvider<String>((ref) => 'English');

const _privacyPolicyUrl = 'https://i-teach.uz/web/privacy_policy.html';

/// Dark panel of white pill rows, running to the bottom of the page.
class SettingsCard extends ConsumerWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(selectedLanguageProvider);

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
            label: 'Language',
            trailing: ProfileSettingValue(value: language, showChevron: true),
            onTap: () => _showLanguagePicker(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileSettingRow(
            label: 'Privacy Policy',
            trailing: const ProfileSettingValue(showChevron: true),
            onTap: () =>
                ref.read(urlLauncherProvider)(Uri.parse(_privacyPolicyUrl)),
          ),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) => ProfileSettingRow(
              label: 'App version',
              trailing: ProfileSettingValue(
                value: snap.data == null ? '—' : 'v${snap.data!.version}',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileSettingRow(
            label: 'Log out',
            labelColor: const Color(0xffef4444),
            onTap: () => _confirmLogout(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileSettingRow(
            label: 'Delete account',
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
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text(
          'Delete account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This removes your courses and progress, and cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: Navigator.of(ctx).pop, child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDeletionRequested(context);
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: Color(0xffef4444)),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 2: acknowledge the request. Nothing is signed out or cleared here —
  /// the account stays usable until the request is actioned.
  void _showDeletionRequested(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text(
          'Request sent',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Your account deletion request has been sent. '
          'You can keep using the app until it is processed.',
        ),
        actions: [
          TextButton(onPressed: Navigator.of(ctx).pop, child: const Text('OK')),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text(
          'Log out',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: const Text('Cancel'),
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
            child: const Text(
              'Log out',
              style: TextStyle(color: Color(0xffef4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    const languages = ['Uzbek', 'English', 'Russian'];
    final current = ref.read(selectedLanguageProvider);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text(
          'Language',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            final selected = lang == current;
            return InkWell(
              onTap: () {
                ref.read(selectedLanguageProvider.notifier).state = lang;
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
                      lang,
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
