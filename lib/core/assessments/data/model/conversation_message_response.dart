import 'package:student/core/assessments/domain/entity/conversation_message_entity.dart';

class ConversationMessageResponse {
  final String id;
  final String role;
  final String text;
  final String? audioPath;
  final String createdAt;

  const ConversationMessageResponse({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.audioPath,
  });

  factory ConversationMessageResponse.fromJson(Map<String, dynamic> json) {
    return ConversationMessageResponse(
      id: json['id'] as String,
      role: json['role'] as String,
      text: json['text'] as String? ?? '',
      audioPath: json['audioPath'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  ConversationMessageEntity toEntity() {
    return ConversationMessageEntity(
      id: id,
      role: role == 'assistant'
          ? AssessmentRole.assistant
          : AssessmentRole.user,
      text: text,
      audioPath: audioPath,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
