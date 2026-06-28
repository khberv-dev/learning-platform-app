import 'package:student/core/user/domain/entity/user_entity.dart';

class UserResponse {
  final String id;
  final String firstName;
  final String? lastName;
  final String phoneNumber;
  final int points;
  final int coins;
  final String level;
  final int balance;

  const UserResponse({
    required this.id,
    required this.firstName,
    required this.phoneNumber,
    required this.points,
    required this.coins,
    required this.level,
    required this.balance,
    this.lastName,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return UserResponse(
      id: json['id'] as String,
      firstName: user['firstName'] as String? ?? '',
      lastName: user['lastName'] as String?,
      phoneNumber: user['phoneNumber'] as String? ?? '',
      points: (json['points'] ?? 0) as int,
      coins: (json['coins'] ?? 0) as int,
      level: json['level'] as String? ?? '—',
      balance: (json['balance'] ?? 0) as int,
    );
  }

  UserEntity toEntity() => UserEntity(
    id: id,
    firstName: firstName,
    lastName: lastName,
    phoneNumber: phoneNumber,
    points: points,
    coins: coins,
    level: level,
    balance: balance,
  );
}
