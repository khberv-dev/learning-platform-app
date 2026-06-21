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

  String get fullName =>
      (lastName != null && lastName!.isNotEmpty) ? '$firstName $lastName' : firstName;

  String get initials {
    final parts = fullName.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : firstName.isNotEmpty
        ? firstName[0].toUpperCase()
        : '?';
  }
}

class ChatMemberEntity {
  final String id;
  final String userId;
  final String firstName;
  final String? lastName;

  const ChatMemberEntity({
    required this.id,
    required this.userId,
    required this.firstName,
    this.lastName,
  });
}

class ChatRoomEntity {
  final String id;
  final bool isGroup;
  final List<ChatMemberEntity> members;
  final String updatedAt;
  final ChatUserEntity? mentor;

  const ChatRoomEntity({
    required this.id,
    required this.isGroup,
    required this.members,
    required this.updatedAt,
    this.mentor,
  });
}
