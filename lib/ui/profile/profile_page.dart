import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/ui/profile/widget/avatar_card.dart';
import 'package:student/ui/profile/widget/personal_info_card.dart';
import 'package:student/ui/profile/widget/settings_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: const SizedBox(
            height: 56,
            child: Center(
              child: Text(
                'Profile',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                AvatarCard(user: user),
                const SizedBox(height: 12),
                PersonalInfoCard(user: user),
                const SizedBox(height: 12),
                const SettingsCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
