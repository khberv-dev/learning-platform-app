import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/assignments/domain/entity/assignment_entity.dart';
import 'package:student/core/assignments/domain/usecase/use_create_assignment.dart';

final createAssignmentControllerProvider =
    AsyncNotifierProvider<CreateAssignmentController, AssignmentEntity?>(
      CreateAssignmentController.new,
    );

class CreateAssignmentController extends AsyncNotifier<AssignmentEntity?> {
  @override
  FutureOr<AssignmentEntity?> build() => null;

  Future<void> book({
    required String teacherId,
    Map<String, List<String>>? selectedSchedule,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(useCreateAssignmentProvider)
          .call(
            teacherId: teacherId,
            startDate: DateTime.now(),
            selectedSchedule: selectedSchedule,
          ),
    );
  }
}
