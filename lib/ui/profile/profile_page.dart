import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/core/subscriptions/domain/entity/subscription_entity.dart';
import 'package:student/core/subscriptions/presentation/my_subscriptions_controller.dart';
import 'package:student/core/user/domain/usecase/use_upload_avatar.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/core/user/presentation/streak_provider.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/plans/plans_screen.dart';
import 'package:student/ui/profile/widget/profile_header_card.dart';
import 'package:student/ui/profile/widget/profile_stats_grid.dart';
import 'package:student/ui/profile/widget/settings_card.dart';
import 'package:student/ui/profile/widget/subscription_card.dart';
import 'package:student/utils/lib.dart';
import 'package:student/utils/messenger.dart';

const _background = Color(0xFFEFEEF4);
const _ink = Color(0xFF15141A);

/// Tab index of Courses in the navbar, where "Choose a plan" leads — plans
/// are sold per course.
const _coursesTabIndex = 1;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _uploadingAvatar = ValueNotifier(false);

  @override
  void dispose() {
    _uploadingAvatar.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    if (_uploadingAvatar.value) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    _uploadingAvatar.value = true;
    try {
      final updated = await ref.read(useUploadAvatarProvider).call(picked.path);
      final current = ref.read(currentUserProvider);
      ref.read(currentUserProvider.notifier).state =
          current?.copyWith(avatar: updated.avatar) ?? updated;
    } catch (e) {
      if (mounted) showErrorMessage(context, apiErrorMessage(context, e));
    } finally {
      if (mounted) _uploadingAvatar.value = false;
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(mySubscriptionsControllerProvider);
    ref.invalidate(streakProvider);
    await ref.read(mySubscriptionsControllerProvider.future);
  }

  void _showAccount() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AccountSheet(
        uploading: _uploadingAvatar,
        onChangePhoto: _changePhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final subscriptions = ref.watch(mySubscriptionsControllerProvider).value;
    final streak = ref.watch(streakProvider).value;
    final insets = MediaQuery.paddingOf(context);

    return ColoredBox(
      color: _background,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            insets.top + AppSpacing.lg,
            AppSpacing.lg,
            insets.bottom + AppSpacing.xl,
          ),
          children: [
            Text(
              l10n.navProfile,
              style: const TextStyle(
                color: _ink,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ProfileHeaderCard(user: user, onTap: _showAccount),
            // Nothing while loading or on failure — a wrong "no plan" card
            // would be worse than a moment without one.
            if (subscriptions != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ..._planCards(context, subscriptions),
            ],
            const SizedBox(height: AppSpacing.lg),
            ProfileStatsGrid(
              streakDays: streak?.currentStreak ?? 0,
              points: user?.points ?? 0,
              coins: user?.coins ?? 0,
            ),
            const SizedBox(height: AppSpacing.xl),
            const SettingsCard(),
          ],
        ),
      ),
    );
  }

  List<Widget> _planCards(
    BuildContext context,
    List<SubscriptionEntity> subscriptions,
  ) {
    final status = PlanStatus.of(subscriptions, DateTime.now());
    return switch (status) {
      PlanActive(:final subscriptions) => [
        for (var i = 0; i < subscriptions.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          ActivePlanCard(
            key: ValueKey('plan-active-${subscriptions[i].id}'),
            subscription: subscriptions[i],
          ),
        ],
      ],
      PlanNone() => [
        PlanPromptCard.none(
          context,
          onChoose: () => ref.read(navbarControllerProvider.notifier).state =
              _coursesTabIndex,
        ),
      ],
      PlanExpired(:final latest) => [
        PlanPromptCard.expired(
          context,
          latest: latest,
          onRenew: () =>
              context.push('${PlansScreen.path}?courseId=${latest.course.id}'),
        ),
      ],
    };
  }
}

/// The student's photo (with a way to change it), name, phone and email.
class _AccountSheet extends ConsumerWidget {
  final ValueNotifier<bool> uploading;
  final VoidCallback onChangePhoto;

  const _AccountSheet({required this.uploading, required this.onChangePhoto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final phone = user?.phoneNumber ?? '';
    final email = user?.email ?? '';

    Widget field(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF8A8C9C), fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: ProfileAvatar(url: user?.avatar, size: 88)),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: uploading,
                builder: (_, isUploading, _) => isUploading
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: onChangePhoto,
                        child: Text(l10n.registerChangePhoto),
                      ),
              ),
            ),
            Text(
              user?.fullName ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (phone.isNotEmpty) field(l10n.fieldPhone, formatPhone(phone)),
            if (email.isNotEmpty) field(l10n.fieldEmail, email),
          ],
        ),
      ),
    );
  }
}
