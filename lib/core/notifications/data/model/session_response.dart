import 'package:student/core/notifications/domain/entity/session_entity.dart';

class SessionResponse {
  final String id;
  final SessionOs? os;
  final String fcmToken;

  const SessionResponse({required this.id, required this.fcmToken, this.os});

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      SessionResponse(
        id: json['id'].toString(),
        os: switch (json['os'] as String?) {
          'android' => SessionOs.android,
          'ios' => SessionOs.ios,
          _ => null,
        },
        fcmToken: json['fcmToken'] as String? ?? '',
      );

  SessionEntity toEntity() => SessionEntity(id: id, os: os, fcmToken: fcmToken);
}
