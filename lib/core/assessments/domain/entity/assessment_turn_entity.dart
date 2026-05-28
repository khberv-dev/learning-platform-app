import 'package:student/core/assessments/domain/entity/conversation_message_entity.dart';

class AssessmentTurnEntity {
  final ConversationMessageEntity userMessage;
  final ConversationMessageEntity assistantMessage;

  const AssessmentTurnEntity({
    required this.userMessage,
    required this.assistantMessage,
  });
}
