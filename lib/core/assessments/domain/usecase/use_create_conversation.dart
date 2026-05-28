import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/assessments/data/repository/assessment_repository.dart';
import 'package:student/core/assessments/domain/entity/conversation_entity.dart';
import 'package:student/core/assessments/domain/repository/i_assessment_repository.dart';

final useCreateConversationProvider = Provider(
  (ref) => UseCreateConversation(ref.read(assessmentRepositoryProvider)),
);

class UseCreateConversation {
  final IAssessmentRepository _repository;

  const UseCreateConversation(this._repository);

  Future<ConversationEntity> call() => _repository.createConversation();
}
