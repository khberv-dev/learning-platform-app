import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/core/notifications/presentation/unread_notifications_count_provider.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/notification_icon_button.dart';
import 'package:student/ui/notifications/notifications_screen.dart';

/// Plain-language name for a CEFR level, which is what the design shows under
/// the user's name rather than the raw "B1".
String levelLabel(AppLocalizations l10n, String cefr) =>
    switch (cefr.toUpperCase()) {
      'A1' || 'A2' => l10n.levelBeginner,
      'B1' || 'B2' => l10n.levelIntermediate,
      'C1' || 'C2' => l10n.levelAdvanced,
      _ => cefr,
    };

class HomeTopbar extends ConsumerWidget {
  const HomeTopbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          // UserEntity carries no avatar URL, so fall back to initials.
          CircleAvatar(
            radius: 27,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              user?.initials ?? '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.fullName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  levelLabel(AppLocalizations.of(context), user?.level ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff9aa5ad),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          NotificationIconButton(
            badgeCount: unreadCount,
            onTap: () => context.push(NotificationsScreen.path),
          ),
        ],
      ),
    );
  }
}
