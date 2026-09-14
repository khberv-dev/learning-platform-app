import 'package:student/core/assessments/domain/entity/assessment_turn_entity.dart';
import 'package:student/core/assessments/domain/entity/conversation_entity.dart';

abstract class IAssessmentRepository {
  Future<String> getAssemblyAiKey();

  Future<ConversationEntity> createConversation();

  Future<AssessmentTurnEntity> sendTurn({
    required String conversationId,
    required String audioFilePath,
  });
}
