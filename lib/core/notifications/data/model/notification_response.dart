import 'package:student/core/notifications/domain/entity/notification_entity.dart';

class NotificationResponse {
  final String id;
  final String title;
  final String body;
  final Map<String, String>? data;
  final DateTime createdAt;
  final bool isRead;

  const NotificationResponse({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return NotificationResponse(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      data: rawData is Map
          ? rawData.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  NotificationEntity toEntity() => NotificationEntity(
    id: id,
    title: title,
    body: body,
    data: data,
    createdAt: createdAt,
    isRead: isRead,
  );
}
