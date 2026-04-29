class UserEntity {
  final String id;
  final String firstName;
  final String? lastName;
  final String phoneNumber;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.phoneNumber,
    this.lastName,
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
}
