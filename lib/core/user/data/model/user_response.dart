import 'package:student/core/user/domain/entity/user_entity.dart';

class UserResponse {
  final String id;
  final String firstName;
  final String? lastName;
  final String phoneNumber;

  const UserResponse({
    required this.id,
    required this.firstName,
    required this.phoneNumber,
    this.lastName,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    id: json['id'] as String,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String?,
    phoneNumber: json['phoneNumber'] as String? ?? '',
  );

  UserEntity toEntity() => UserEntity(
    id: id,
    firstName: firstName,
    lastName: lastName,
    phoneNumber: phoneNumber,
  );
}
