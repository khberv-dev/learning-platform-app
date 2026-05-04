import 'package:student/core/assessments/domain/entity/assessment_feedback_entity.dart';

abstract class IAssessmentRepository {
  Future<AssessmentFeedbackEntity> submit({required String audioFilePath});
}
