import 'package:student/core/assignments/domain/entity/assignment_entity.dart';

abstract class IAssignmentsRepository {
  Future<AssignmentEntity> createAssignment({
    required String teacherId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
