import 'package:student/core/chat/domain/entity/chat_room_entity.dart';

class ChatUserResponse {
  final String id;
  final String firstName;
  final String? lastName;
  final String? avatar;

  const ChatUserResponse({
    required this.id,
    required this.firstName,
    this.lastName,
    this.avatar,
  });

  factory ChatUserResponse.fromJson(Map<String, dynamic> json) =>
      ChatUserResponse(
        id: json['id'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String?,
        avatar: json['avatar'] as String?,
      );

  ChatUserEntity toEntity() => ChatUserEntity(
    id: id,
    firstName: firstName,
    lastName: lastName,
    avatar: avatar,
  );
}

class ChatMemberResponse {
  final String id;
  final String userId;
  final String firstName;
  final String? lastName;

  const ChatMemberResponse({
    required this.id,
    required this.userId,
    required this.firstName,
    this.lastName,
  });

  factory ChatMemberResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return ChatMemberResponse(
      id: json['id'] as String? ?? '',
      userId: user['id'] as String? ?? '',
      firstName: user['firstName'] as String? ?? '',
      lastName: user['lastName'] as String?,
    );
  }

  ChatMemberEntity toEntity() => ChatMemberEntity(
    id: id,
    userId: userId,
    firstName: firstName,
    lastName: lastName,
  );
}

class ChatRoomResponse {
  final String id;
  final bool isGroup;
  final List<ChatMemberResponse> members;
  final String updatedAt;
  final ChatUserResponse? mentor;

  const ChatRoomResponse({
    required this.id,
    required this.isGroup,
    required this.members,
    required this.updatedAt,
    this.mentor,
  });

  factory ChatRoomResponse.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    final rawMentor = json['mentor'] as Map<String, dynamic>?;
    return ChatRoomResponse(
      id: json['id'] as String,
      isGroup: json['isGroup'] as bool? ?? false,
      members: rawMembers
          .map((e) => ChatMemberResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      updatedAt: json['updatedAt'] as String? ?? '',
      mentor: rawMentor != null ? ChatUserResponse.fromJson(rawMentor) : null,
    );
  }

  ChatRoomEntity toEntity() => ChatRoomEntity(
    id: id,
    isGroup: isGroup,
    members: members.map((m) => m.toEntity()).toList(),
    updatedAt: updatedAt,
    mentor: mentor?.toEntity(),
  );
}
