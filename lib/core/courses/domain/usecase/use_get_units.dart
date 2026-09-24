import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final useGetUnitsProvider = Provider(
  (ref) => UseGetUnits(ref.read(coursesRepositoryProvider)),
);

class UseGetUnits {
  final ICoursesRepository _repository;

  const UseGetUnits(this._repository);

  Future<List<UnitEntity>> call(String courseId) =>
      _repository.getUnits(courseId);
}
