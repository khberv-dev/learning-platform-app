import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/assessments/data/repository/assessment_repository.dart';
import 'package:student/core/assessments/domain/entity/assessment_turn_entity.dart';
import 'package:student/core/assessments/domain/repository/i_assessment_repository.dart';

final useSendAssessmentTurnProvider = Provider(
  (ref) => UseSendAssessmentTurn(ref.read(assessmentRepositoryProvider)),
);

class UseSendAssessmentTurn {
  final IAssessmentRepository _repository;

  const UseSendAssessmentTurn(this._repository);

  Future<AssessmentTurnEntity> call({
    required String conversationId,
    required String audioFilePath,
  }) => _repository.sendTurn(
    conversationId: conversationId,
    audioFilePath: audioFilePath,
  );
}
