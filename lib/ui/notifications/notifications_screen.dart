import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/notifications/domain/entity/notification_entity.dart';
import 'package:student/core/notifications/presentation/notifications_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/back_icon_button.dart';
import 'package:student/utils/date_format.dart';
import 'package:student/utils/messenger.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  static const path = '/notifications';
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
  }

  void _loadMore() {
    if (_scrollController.position.extentAfter < 240) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(notificationsProvider);
    await ref.read(notificationsProvider.future);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const BackIconButton(),
        leadingWidth: 64,
        titleSpacing: 0,
        title: Text(
          l10n.notificationsTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _NotificationsError(
          message: apiErrorMessage(context, error),
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (page) => RefreshIndicator(
          onRefresh: _refresh,
          child: page.notifications.isEmpty
              ? _NotificationsEmpty(
                  title: l10n.notificationsEmptyTitle,
                  subtitle: l10n.notificationsEmptySubtitle,
                )
              : ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
                  ),
                  itemCount: page.notifications.length + (page.hasMore ? 1 : 0),
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) =>
                      index == page.notifications.length
                      ? const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _NotificationCard(
                          notification: page.notifications[index],
                          onTap: () => _markAsRead(page.notifications[index]),
                        ),
                ),
        ),
      ),
    );
  }

  Future<void> _markAsRead(NotificationEntity notification) async {
    if (notification.isRead) return;
    try {
      await ref
          .read(notificationsProvider.notifier)
          .markAsRead(notification.id);
    } catch (error) {
      if (mounted) showErrorMessage(context, apiErrorMessage(context, error));
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = notification.createdAt.toLocal();
    return Material(
      color: notification.isRead ? Colors.white : const Color(0xFFF0FDF4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: notification.isRead
              ? const Color(0xFFE5E7EB)
              : Theme.of(context).colorScheme.primary.withValues(alpha: .35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/icons/bell.svg',
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        color: const Color(0xFF111827),
                        fontSize: 16,
                        fontWeight: notification.isRead
                            ? FontWeight.w600
                            : FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${formatShortDate(context, date)} · ${formatTime(context, date)}',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsEmpty extends StatelessWidget {
  final String title;
  final String subtitle;
  const _NotificationsEmpty({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(height: MediaQuery.sizeOf(context).height * .2),
      SvgPicture.asset(
        'assets/icons/bell.svg',
        width: 64,
        height: 64,
        colorFilter: const ColorFilter.mode(Color(0xFFD1D5DB), BlendMode.srcIn),
      ),
      const SizedBox(height: AppSpacing.lg),
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
      ),
    ],
  );
}

class _NotificationsError extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;
  const _NotificationsError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 180,
            child: AppButton.outlined(label: retryLabel, onTap: onRetry),
          ),
        ],
      ),
    ),
  );
}
