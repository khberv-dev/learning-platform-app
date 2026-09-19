import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/enrollments/domain/entity/enrollment_history_entity.dart';
import 'package:student/core/enrollments/domain/usecase/use_get_enrollment_history.dart';

final enrollmentHistoryControllerProvider =
    AsyncNotifierProvider<
      EnrollmentHistoryController,
      List<EnrollmentHistoryEntity>
    >(EnrollmentHistoryController.new);

class EnrollmentHistoryController
    extends AsyncNotifier<List<EnrollmentHistoryEntity>> {
  @override
  FutureOr<List<EnrollmentHistoryEntity>> build() =>
      ref.read(useGetEnrollmentHistoryProvider).call();
}
