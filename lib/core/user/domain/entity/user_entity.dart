class UserEntity {
  final String id;
  final String firstName;
  final String? lastName;
  final String? avatar;
  final String phoneNumber;
  final String? email;
  final int points;
  final int coins;
  final String level;

  const UserEntity({
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

  String get fullName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
  }

  UserEntity copyWith({String? avatar}) => UserEntity(
    id: id,
    firstName: firstName,
    lastName: lastName,
    avatar: avatar ?? this.avatar,
    phoneNumber: phoneNumber,
    email: email,
    points: points,
    coins: coins,
    level: level,
  );
}
