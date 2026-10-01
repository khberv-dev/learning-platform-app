import 'package:student/core/assignments/domain/entity/assignment_entity.dart';

abstract class IAssignmentsRepository {
  /// Every group request the student has made, pending or active.
  Future<List<AssignmentEntity>> getMyAssignments();

  /// Asks to be placed in a group for [subscriptionId] at these weekly times.
  Future<AssignmentEntity> requestAssignment({
    required String subscriptionId,
    required List<ScheduleSlot> schedule,
  });
}
