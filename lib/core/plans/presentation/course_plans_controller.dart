import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/plans/domain/entity/plan_entity.dart';
import 'package:student/core/plans/domain/usecase/use_get_course_plans.dart';

/// Plans a course can be bought on, keyed by course id.
final coursePlansControllerProvider =
    FutureProvider.family<List<PlanEntity>, String>(
      (ref, courseId) => ref.read(useGetCoursePlansProvider).call(courseId),
    );
