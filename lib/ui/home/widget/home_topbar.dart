import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/notifications/presentation/unread_notifications_count_provider.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_balance_chip.dart';
import 'package:student/ui/notifications/notifications_screen.dart';
import 'package:student/utils/lib.dart';

const _muted = Color(0xFF717384);
const _ink = Color(0xFF15141A);
const _placeholderIcon = Color(0xFFA5A6B9);

/// Home's greeting row: the student's photo (or a person placeholder), a
/// "Good day, Name!" greeting, their points and coins, and a bell into
/// notifications.
class HomeTopbar extends ConsumerWidget {
  const HomeTopbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final unread = ref.watch(unreadNotificationsCountProvider).value ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          _Avatar(url: resolveMediaUrl(user?.avatar)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.homeGreeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  l10n.homeGreetingName(user?.firstName ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppBalanceChip(
            key: const ValueKey('home-points'),
            imagePath: 'assets/images/ic_point.png',
            value: user?.points ?? 0,
            semanticsLabel: l10n.homeStatsScores,
          ),
          const SizedBox(width: AppSpacing.sm),
          AppBalanceChip(
            key: const ValueKey('home-coins'),
            imagePath: 'assets/images/ic_coin.png',
            value: user?.coins ?? 0,
            semanticsLabel: l10n.homeStatsCoins,
          ),
          const SizedBox(width: AppSpacing.sm),
          _NotificationsButton(
            hasUnread: unread > 0,
            onTap: () => context.push(NotificationsScreen.path),
          ),
        ],
      ),
    );
  }
}

/// A white rounded tile: the photo, or a grey person outline without one.
class _Avatar extends StatelessWidget {
  final String? url;

  const _Avatar({required this.url});

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    const placeholder = Center(
      child: Icon(
        Icons.person_outline_rounded,
        size: 26,
        color: _placeholderIcon,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 40,
        height: 40,
        color: Colors.white,
        child: url == null
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

/// A white rounded tile with a bell, matching the balance chips beside it. A
/// red dot on its corner means there are unread notifications.
class _NotificationsButton extends StatelessWidget {
  final bool hasUnread;
  final VoidCallback onTap;

  const _NotificationsButton({required this.hasUnread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).notificationsTitle,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset('assets/icons/bell.svg', width: 18),
            ),
            if (hasUnread)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  key: const ValueKey('notifications-unread-dot'),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC5A53),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
