import 'package:student/core/notifications/domain/entity/session_entity.dart';

abstract class INotificationsRepository {
  /// Hands the device's FCM token to the API so it can be pushed to.
  Future<SessionEntity> registerSession({
    required SessionOs os,
    required String fcmToken,
  });

  /// Drops the device's registration on logout, so the API stops pushing to it.
  Future<void> deleteSession(String id);
}
