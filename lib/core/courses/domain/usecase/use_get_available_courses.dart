import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final useGetAvailableCoursesProvider = Provider(
  (ref) => UseGetAvailableCourses(ref.read(coursesRepositoryProvider)),
);

class UseGetAvailableCourses {
  final ICoursesRepository _repository;

  const UseGetAvailableCourses(this._repository);

  Future<List<CourseEntity>> call() => _repository.getAvailable();
}
