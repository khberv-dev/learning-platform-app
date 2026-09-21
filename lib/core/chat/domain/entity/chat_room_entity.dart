class ChatUserEntity {
  final String id;
  final String firstName;
  final String? lastName;
  final String? avatar;

  const ChatUserEntity({
    required this.id,
    required this.firstName,
    this.lastName,
    this.avatar,
  });

  String get fullName => (lastName != null && lastName!.isNotEmpty)
      ? '$firstName $lastName'
      : firstName;

  String get initials {
    final parts = fullName.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : firstName.isNotEmpty
        ? firstName[0].toUpperCase()
        : '?';
  }
}

class ChatGroupEntity {
  final String id;
  final String title;

  const ChatGroupEntity({required this.id, required this.title});
}

/// Every chat room is a group's room now — there's no more 1:1 mentor chat.
class ChatRoomEntity {
  final String id;
  final ChatGroupEntity? group;
  final String updatedAt;

  /// The group's primary mentor. Null if none is assigned yet, or on the
  /// unflattened list-endpoint shape.
  final ChatUserEntity? mentor;

  /// The group's current student roster. Empty on the unflattened
  /// list-endpoint shape.
  final List<ChatUserEntity> students;

  const ChatRoomEntity({
    required this.id,
    required this.updatedAt,
    this.group,
    this.mentor,
    this.students = const [],
  });
}
