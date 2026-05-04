import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/assessments/data/repository/assessment_repository.dart';
import 'package:student/core/assessments/domain/entity/assessment_feedback_entity.dart';
import 'package:student/core/assessments/domain/repository/i_assessment_repository.dart';

final useSubmitAssessmentProvider = Provider(
  (ref) => UseSubmitAssessment(ref.read(assessmentRepositoryProvider)),
);

class UseSubmitAssessment {
  final IAssessmentRepository _repository;

  const UseSubmitAssessment(this._repository);

  Future<AssessmentFeedbackEntity> call({required String audioFilePath}) =>
      _repository.submit(audioFilePath: audioFilePath);
}
