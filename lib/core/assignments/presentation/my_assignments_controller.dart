import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/assignments/domain/entity/assignment_entity.dart';
import 'package:student/core/assignments/domain/usecase/assignment_usecases.dart';

final myAssignmentsControllerProvider =
    AsyncNotifierProvider<MyAssignmentsController, List<AssignmentEntity>>(
      MyAssignmentsController.new,
    );

class MyAssignmentsController extends AsyncNotifier<List<AssignmentEntity>> {
  @override
  FutureOr<List<AssignmentEntity>> build() =>
      ref.read(useGetMyAssignmentsProvider).call();
}
