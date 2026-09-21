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

class ChatGroupResponse {
  final String id;
  final String title;

  const ChatGroupResponse({required this.id, required this.title});

  factory ChatGroupResponse.fromJson(Map<String, dynamic> json) =>
      ChatGroupResponse(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
      );

  ChatGroupEntity toEntity() => ChatGroupEntity(id: id, title: title);
}

class ChatRoomResponse {
  final String id;
  final String updatedAt;
  final ChatGroupResponse? group;
  final ChatUserResponse? mentor;
  final List<ChatUserResponse> students;

  const ChatRoomResponse({
    required this.id,
    required this.updatedAt,
    this.group,
    this.mentor,
    this.students = const [],
  });

  // The list endpoint only attaches `group`; the detail endpoint additionally
  // flattens the group's primary mentor and current student roster.
  factory ChatRoomResponse.fromJson(Map<String, dynamic> json) {
    final rawGroup = json['group'] as Map<String, dynamic>?;
    final rawMentor = json['mentor'] as Map<String, dynamic>?;
    final rawStudents = json['students'] as List<dynamic>? ?? [];
    return ChatRoomResponse(
      id: json['id'] as String,
      updatedAt: json['updatedAt'] as String? ?? '',
      group: rawGroup != null ? ChatGroupResponse.fromJson(rawGroup) : null,
      mentor: rawMentor != null ? ChatUserResponse.fromJson(rawMentor) : null,
      students: rawStudents
          .map((e) => ChatUserResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ChatRoomEntity toEntity() => ChatRoomEntity(
    id: id,
    updatedAt: updatedAt,
    group: group?.toEntity(),
    mentor: mentor?.toEntity(),
    students: students.map((s) => s.toEntity()).toList(),
  );
}
