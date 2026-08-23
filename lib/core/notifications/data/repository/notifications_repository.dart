import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/notifications/data/model/notification_response.dart';
import 'package:student/core/notifications/data/model/session_response.dart';
import 'package:student/core/notifications/domain/entity/notifications_page_entity.dart';
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

  @override
  Future<NotificationsPageEntity> getMine({
    required int page,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      'notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    final json = response.data as Map<String, dynamic>;
    final rows = json['data'] as List<dynamic>? ?? const [];
    return NotificationsPageEntity(
      notifications: rows
          .map(
            (row) => NotificationResponse.fromJson(
              row as Map<String, dynamic>,
            ).toEntity(),
          )
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? page,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get(
      'notifications/unread',
      queryParameters: {'page': 1, 'limit': 1},
    );
    final json = response.data as Map<String, dynamic>;
    return (json['total'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> markAsRead(String id) async {
    await _dio.patch('notifications/$id/read');
  }
}
