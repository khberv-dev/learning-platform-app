import 'package:student/core/notifications/domain/entity/notifications_page_entity.dart';
import 'package:student/core/notifications/domain/entity/session_entity.dart';

abstract class INotificationsRepository {
  Future<SessionEntity> registerSession({
    required SessionOs os,
    required String fcmToken,
  });

  Future<void> deleteSession(String id);

  Future<NotificationsPageEntity> getMine({required int page, int limit = 20});
}
