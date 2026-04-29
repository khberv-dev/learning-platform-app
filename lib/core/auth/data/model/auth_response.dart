import 'package:student/core/auth/domain/entity/auth_entity.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;

  const AuthResponse({required this.accessToken, required this.refreshToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: (json['accessToken'] ?? json['access_token']) as String,
    refreshToken: (json['refreshToken'] ?? json['refresh_token']) as String,
  );

  AuthEntity toEntity() =>
      AuthEntity(accessToken: accessToken, refreshToken: refreshToken);
}
