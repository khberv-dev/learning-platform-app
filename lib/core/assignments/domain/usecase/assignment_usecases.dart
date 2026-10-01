import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/assignments/data/repository/assignments_repository.dart';
import 'package:student/core/assignments/domain/entity/assignment_entity.dart';
import 'package:student/core/assignments/domain/repository/i_assignments_repository.dart';

final useGetMyAssignmentsProvider = Provider<UseGetMyAssignments>(
  (ref) => UseGetMyAssignments(ref.read(assignmentsRepositoryProvider)),
);

class UseGetMyAssignments {
  final IAssignmentsRepository _repository;

  const UseGetMyAssignments(this._repository);

  Future<List<AssignmentEntity>> call() => _repository.getMyAssignments();
}

final useRequestAssignmentProvider = Provider<UseRequestAssignment>(
  (ref) => UseRequestAssignment(ref.read(assignmentsRepositoryProvider)),
);

class UseRequestAssignment {
  final IAssignmentsRepository _repository;

  const UseRequestAssignment(this._repository);

  Future<AssignmentEntity> call({
    required String subscriptionId,
    required List<ScheduleSlot> schedule,
  }) => _repository.requestAssignment(
    subscriptionId: subscriptionId,
    schedule: schedule,
  );
}
