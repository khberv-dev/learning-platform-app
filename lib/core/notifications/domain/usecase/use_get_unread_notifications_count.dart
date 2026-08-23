import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/notifications/data/repository/notifications_repository.dart';
import 'package:student/core/notifications/domain/repository/i_notifications_repository.dart';

final useGetUnreadNotificationsCountProvider = Provider(
  (ref) =>
      UseGetUnreadNotificationsCount(ref.read(notificationsRepositoryProvider)),
);

class UseGetUnreadNotificationsCount {
  final INotificationsRepository _repository;

  const UseGetUnreadNotificationsCount(this._repository);

  Future<int> call() => _repository.getUnreadCount();
}
