import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/notifications/data/repository/notifications_repository.dart';
import 'package:student/core/notifications/domain/repository/i_notifications_repository.dart';

final useDeleteSessionProvider = Provider(
  (ref) => UseDeleteSession(ref.read(notificationsRepositoryProvider)),
);

class UseDeleteSession {
  final INotificationsRepository _repository;

  const UseDeleteSession(this._repository);

  Future<void> call(String id) => _repository.deleteSession(id);
}
