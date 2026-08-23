import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/notifications/domain/entity/notifications_page_entity.dart';
import 'package:student/core/notifications/domain/usecase/use_get_notifications.dart';

final notificationsProvider =
    AsyncNotifierProvider<NotificationsController, NotificationsPageEntity>(
      NotificationsController.new,
    );

class NotificationsController extends AsyncNotifier<NotificationsPageEntity> {
  bool _loadingMore = false;

  @override
  FutureOr<NotificationsPageEntity> build() =>
      ref.read(useGetNotificationsProvider).call(page: 1);

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _loadingMore) return;

    _loadingMore = true;
    try {
      final next = await ref
          .read(useGetNotificationsProvider)
          .call(page: current.page + 1);
      state = AsyncData(
        NotificationsPageEntity(
          notifications: [...current.notifications, ...next.notifications],
          page: next.page,
          totalPages: next.totalPages,
        ),
      );
    } catch (_) {
      // Keep the pages already on screen. A later scroll or pull-to-refresh
      // can retry without replacing useful content with a full-page error.
    } finally {
      _loadingMore = false;
    }
  }
}
