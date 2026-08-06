import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/ui/auth/forgot_password_screen.dart';
import 'package:student/ui/profile/widget/profile_hero.dart';
import 'package:student/ui/profile/widget/profile_pill.dart';
import 'package:student/ui/profile/widget/settings_card.dart';
import 'package:student/utils/lib.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHero(user: user),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              children: [
                ProfileField(
                  label: 'Phone number',
                  value: formatPhone(user?.phoneNumber),
                ),
                const SizedBox(height: AppSpacing.lg),
                ProfileField(
                  label: 'Password',
                  value: 'Update password',
                  // Reuses the recovery flow — it verifies by OTP and sets a
                  // new password, which is what updating one means here.
                  onTap: () => context.push(ForgotPasswordScreen.path),
                ),
              ],
            ),
          ),
          const SettingsCard(),
        ],
      ),
    );
  }
}
