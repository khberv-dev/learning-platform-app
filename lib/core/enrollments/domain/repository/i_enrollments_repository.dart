import 'package:student/core/enrollments/domain/entity/enrollment_history_entity.dart';

abstract class IEnrollmentsRepository {
  /// Every purchase term this student has ever had, newest first.
  Future<List<EnrollmentHistoryEntity>> getHistory();
}
