import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/notifications/data/model/session_response.dart';
import 'package:student/core/notifications/domain/entity/session_entity.dart';
import 'package:student/core/notifications/domain/repository/i_notifications_repository.dart';

final notificationsRepositoryProvider = Provider<INotificationsRepository>(
  (ref) => NotificationsRepository(dio: ref.read(dioClientProvider)),
);

class NotificationsRepository implements INotificationsRepository {
  final Dio _dio;

  const NotificationsRepository({required Dio dio}) : _dio = dio;

  @override
  Future<SessionEntity> registerSession({
    required SessionOs os,
    required String fcmToken,
  }) async {
    final response = await _dio.post(
      'sessions',
      data: {'os': os.value, 'fcmToken': fcmToken},
    );
    return SessionResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }

  @override
  Future<void> deleteSession(String id) async {
    await _dio.delete('sessions/$id');
  }
}
