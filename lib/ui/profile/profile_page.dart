import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/user/domain/usecase/use_upload_avatar.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/auth/forgot_password_screen.dart';
import 'package:student/ui/profile/widget/profile_hero.dart';
import 'package:student/ui/profile/widget/profile_pill.dart';
import 'package:student/ui/profile/widget/settings_card.dart';
import 'package:student/utils/lib.dart';
import 'package:student/utils/messenger.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _uploadingAvatar = false;

  Future<void> _changePhoto() async {
    if (_uploadingAvatar) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    try {
      final updated = await ref.read(useUploadAvatarProvider).call(picked.path);
      final current = ref.read(currentUserProvider);
      ref.read(currentUserProvider.notifier).state =
          current?.copyWith(avatar: updated.avatar) ?? updated;
    } catch (e) {
      if (mounted) showErrorMessage(context, apiErrorMessage(context, e));
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ProfileHero(user: user, photoUrl: user?.avatar),
              Positioned(
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: _ChangePhotoButton(
                  isLoading: _uploadingAvatar,
                  onTap: _changePhoto,
                ),
              ),
            ],
          ),
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
                  label: l10n.profilePhone,
                  value: formatPhone(user?.phoneNumber),
                ),
                const SizedBox(height: AppSpacing.lg),
                ProfileField(
                  label: l10n.profileEmail,
                  value: user?.email?.isNotEmpty == true ? user!.email! : '—',
                ),
                const SizedBox(height: AppSpacing.lg),
                ProfileField(
                  label: l10n.profilePassword,
                  value: l10n.profileUpdatePassword,
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

/// Small circular camera button floated over the hero photo's corner.
class _ChangePhotoButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _ChangePhotoButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isLoading ? null : onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: Colors.black,
                  ),
          ),
        ),
      ),
    );
  }
}
