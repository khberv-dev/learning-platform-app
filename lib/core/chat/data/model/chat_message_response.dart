import 'package:student/core/chat/domain/entity/chat_message_entity.dart';

class ChatMessageResponse {
  final String id;
  final String type;
  final String? text;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final String? fileMimeType;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String createdAt;

  const ChatMessageResponse({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    this.senderAvatar,
    this.text,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.fileMimeType,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    // Exactly one of student/mentor/admin is non-null — that's the sender.
    final sender =
        json['student'] as Map<String, dynamic>? ??
        json['mentor'] as Map<String, dynamic>? ??
        json['admin'] as Map<String, dynamic>? ??
        {};
    final firstName = sender['firstName'] as String? ?? '';
    final lastName = sender['lastName'] as String?;
    final senderName = (lastName != null && lastName.isNotEmpty)
        ? '$firstName $lastName'
        : firstName;

    return ChatMessageResponse(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'text',
      text: json['text'] as String?,
      filePath: json['filePath'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      fileMimeType: json['fileMimeType'] as String?,
      senderId: sender['id'] as String? ?? '',
      senderName: senderName,
      senderAvatar: sender['avatar'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  ChatMessageEntity toEntity() => ChatMessageEntity(
    id: id,
    type: type,
    text: text,
    filePath: filePath,
    fileName: fileName,
    fileSize: fileSize,
    fileMimeType: fileMimeType,
    senderId: senderId,
    senderName: senderName,
    senderAvatar: senderAvatar,
    createdAt: createdAt,
  );
}
