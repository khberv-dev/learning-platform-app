import 'package:student/core/user/domain/entity/user_entity.dart';

class UserResponse {
  final String id;
  final String firstName;
  final String? lastName;
  final String? avatar;
  final String phoneNumber;
  final String? email;
  final int points;
  final int coins;
  final String level;

  const UserResponse({
    required this.id,
    required this.firstName,
    required this.phoneNumber,
    required this.points,
    required this.coins,
    required this.level,
    this.lastName,
    this.avatar,
    this.email,
  });

  // Flat on the wire — no nested `user` object.
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String?,
      avatar: json['avatar'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String?,
      points: (json['points'] ?? 0) as int,
      coins: (json['coins'] ?? 0) as int,
      level: json['level'] as String? ?? '—',
    );
  }

  UserEntity toEntity() => UserEntity(
    id: id,
    firstName: firstName,
    lastName: lastName,
    avatar: avatar,
    phoneNumber: phoneNumber,
    email: email,
    points: points,
    coins: coins,
    level: level,
  );
}
