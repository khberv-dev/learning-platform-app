import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/assignments/data/repository/assignments_repository.dart';
import 'package:student/core/assignments/domain/entity/assignment_entity.dart';
import 'package:student/core/assignments/domain/repository/i_assignments_repository.dart';

final useCreateAssignmentProvider = Provider<UseCreateAssignment>(
  (ref) => UseCreateAssignment(ref.read(assignmentsRepositoryProvider)),
);

class UseCreateAssignment {
  final IAssignmentsRepository _repository;

  const UseCreateAssignment(this._repository);

  Future<AssignmentEntity> call({
    required String teacherId,
    required DateTime startDate,
  }) =>
      _repository.createAssignment(teacherId: teacherId, startDate: startDate);
}
