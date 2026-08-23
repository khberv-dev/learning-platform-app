import 'package:student/core/notifications/domain/entity/notification_entity.dart';

class NotificationsPageEntity {
  final List<NotificationEntity> notifications;
  final int page;
  final int totalPages;

  const NotificationsPageEntity({
    required this.notifications,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
