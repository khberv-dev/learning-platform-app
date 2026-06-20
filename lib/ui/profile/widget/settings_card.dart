import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

final selectedLanguageProvider = StateProvider<String>((ref) => 'English');

class SettingsCard extends ConsumerWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(selectedLanguageProvider);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.language_rounded,
            label: 'Language',
            trailing: Row(
              children: [
                Text(
                  language,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFFD1D5DB),
                ),
              ],
            ),
            onTap: () => _showLanguagePicker(context, ref),
          ),
          _divider(),
          _SettingsRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFFD1D5DB),
            ),
            onTap: () => launchUrl(
              Uri.parse('https://i-teach.uz/web/privacy_policy.html'),
              mode: LaunchMode.inAppBrowserView,
            ),
          ),
          _divider(),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) {
              final version = snap.data != null
                  ? 'v${snap.data!.version}'
                  : '—';
              return _SettingsRow(
                icon: Icons.info_outline_rounded,
                label: 'App Version',
                trailing: Text(
                  version,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
          _divider(),
          _SettingsRow(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            danger: true,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFFEF4444),
            ),
            onTap: () => _confirmLogout(context, ref),
          ),
          _divider(),
          _SettingsRow(
            icon: Icons.delete_outline_rounded,
            label: 'Delete Account',
            danger: true,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFFEF4444),
            ),
            onTap: _openDeleteAccount,
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
              await ref.read(tokenStorageProvider).clearAll();
              ref.read(currentUserProvider.notifier).state = null;
              if (context.mounted) context.go(LoginScreen.path);
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _openDeleteAccount() {
    launchUrl(
      Uri.parse('https://i-teach.uz/web/delete_account.html'),
      mode: LaunchMode.inAppBrowserView,
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    const languages = ['Uzbek', 'English', 'Russian'];
    final current = ref.read(selectedLanguageProvider);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Language',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF18C96A)
                            : const Color(0xFF111827),
                        fontSize: 15,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF18C96A),
                        size: 18,
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

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool danger;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _IconBox(icon: icon, danger: danger),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: danger
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final bool danger;

  const _IconBox({required this.icon, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: danger ? const Color(0xFFFEF2F2) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 16,
        color: danger ? const Color(0xFFEF4444) : const Color(0xFF333333),
      ),
    );
  }
}

Widget _divider() =>
    const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6));
