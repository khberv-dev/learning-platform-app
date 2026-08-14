import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/notifications/data/repository/notifications_repository.dart';
import 'package:student/core/notifications/domain/entity/session_entity.dart';
import 'package:student/core/notifications/domain/repository/i_notifications_repository.dart';

final useRegisterSessionProvider = Provider(
  (ref) => UseRegisterSession(ref.read(notificationsRepositoryProvider)),
);

class UseRegisterSession {
  final INotificationsRepository _repository;

  const UseRegisterSession(this._repository);

  Future<SessionEntity> call({
    required SessionOs os,
    required String fcmToken,
  }) => _repository.registerSession(os: os, fcmToken: fcmToken);
}
