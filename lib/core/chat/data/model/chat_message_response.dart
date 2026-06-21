import 'package:student/core/chat/domain/entity/chat_message_entity.dart';

class ChatMessageResponse {
  final String id;
  final String type;
  final String? text;
  final String? filePath;
  final String? fileName;
  final String senderId;
  final String senderName;
  final String createdAt;

  const ChatMessageResponse({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    this.text,
    this.filePath,
    this.fileName,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>? ?? {};
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
      senderId: sender['id'] as String? ?? '',
      senderName: senderName,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  ChatMessageEntity toEntity() => ChatMessageEntity(
    id: id,
    type: type,
    text: text,
    filePath: filePath,
    fileName: fileName,
    senderId: senderId,
    senderName: senderName,
    createdAt: createdAt,
  );
}
