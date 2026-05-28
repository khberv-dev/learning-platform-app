import 'package:student/core/assessments/domain/entity/conversation_entity.dart';

class ConversationResponse {
  final String id;

  const ConversationResponse({required this.id});

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(id: json['id'] as String);
  }

  ConversationEntity toEntity() => ConversationEntity(id: id);
}
