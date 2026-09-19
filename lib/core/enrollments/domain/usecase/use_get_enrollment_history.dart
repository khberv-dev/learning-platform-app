import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/enrollments/data/repository/enrollments_repository.dart';
import 'package:student/core/enrollments/domain/entity/enrollment_history_entity.dart';
import 'package:student/core/enrollments/domain/repository/i_enrollments_repository.dart';

final useGetEnrollmentHistoryProvider = Provider<UseGetEnrollmentHistory>(
  (ref) => UseGetEnrollmentHistory(ref.read(enrollmentsRepositoryProvider)),
);

class UseGetEnrollmentHistory {
  final IEnrollmentsRepository _repo;

  const UseGetEnrollmentHistory(this._repo);

  Future<List<EnrollmentHistoryEntity>> call() => _repo.getHistory();
}
