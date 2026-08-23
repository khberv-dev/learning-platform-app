import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/notifications/data/repository/notifications_repository.dart';
import 'package:student/core/notifications/domain/repository/i_notifications_repository.dart';

final useMarkNotificationAsReadProvider = Provider(
  (ref) => UseMarkNotificationAsRead(ref.read(notificationsRepositoryProvider)),
);

class UseMarkNotificationAsRead {
  final INotificationsRepository _repository;

  const UseMarkNotificationAsRead(this._repository);

  Future<void> call(String id) => _repository.markAsRead(id);
}
