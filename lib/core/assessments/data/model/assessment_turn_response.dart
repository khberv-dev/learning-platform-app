import 'package:student/core/assessments/data/model/conversation_message_response.dart';
import 'package:student/core/assessments/domain/entity/assessment_turn_entity.dart';

class AssessmentTurnResponse {
  final ConversationMessageResponse userMessage;
  final ConversationMessageResponse assistantMessage;

  const AssessmentTurnResponse({
    required this.userMessage,
    required this.assistantMessage,
  });

  factory AssessmentTurnResponse.fromJson(Map<String, dynamic> json) {
    return AssessmentTurnResponse(
      userMessage: ConversationMessageResponse.fromJson(
        json['userMessage'] as Map<String, dynamic>,
      ),
      assistantMessage: ConversationMessageResponse.fromJson(
        json['assistantMessage'] as Map<String, dynamic>,
      ),
    );
  }

  AssessmentTurnEntity toEntity() {
    return AssessmentTurnEntity(
      userMessage: userMessage.toEntity(),
      assistantMessage: assistantMessage.toEntity(),
    );
  }
}
