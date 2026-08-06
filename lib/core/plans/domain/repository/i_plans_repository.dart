import 'package:student/core/plans/domain/entity/plan_entity.dart';

abstract class IPlansRepository {
  /// Active plans for a course, cheapest duration first.
  Future<List<PlanEntity>> getCoursePlans(String courseId);
}
