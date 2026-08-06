import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/plans/data/repository/plans_repository.dart';
import 'package:student/core/plans/domain/entity/plan_entity.dart';
import 'package:student/core/plans/domain/repository/i_plans_repository.dart';

final useGetCoursePlansProvider = Provider<UseGetCoursePlans>(
  (ref) => UseGetCoursePlans(ref.read(plansRepositoryProvider)),
);

class UseGetCoursePlans {
  final IPlansRepository _repo;

  const UseGetCoursePlans(this._repo);

  Future<List<PlanEntity>> call(String courseId) =>
      _repo.getCoursePlans(courseId);
}
