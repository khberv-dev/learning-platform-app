import 'package:student/core/user/domain/entity/user_entity.dart';

class UserResponse {
  final String id;
  final String firstName;
  final String phoneNumber;

  const UserResponse({
    required this.id,
    required this.firstName,
    required this.phoneNumber,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    phoneNumber: json['phoneNumber'] as String,
  );

  UserEntity toEntity() => UserEntity(
    id: id,
    firstName: firstName,
    phoneNumber: phoneNumber,
  );
}
