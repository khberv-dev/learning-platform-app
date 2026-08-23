import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/notifications/data/repository/notifications_repository.dart';
import 'package:student/core/notifications/domain/entity/notifications_page_entity.dart';
import 'package:student/core/notifications/domain/repository/i_notifications_repository.dart';

final useGetNotificationsProvider = Provider(
  (ref) => UseGetNotifications(ref.read(notificationsRepositoryProvider)),
);

class UseGetNotifications {
  final INotificationsRepository _repository;

  const UseGetNotifications(this._repository);

  Future<NotificationsPageEntity> call({required int page}) =>
      _repository.getMine(page: page);
}
