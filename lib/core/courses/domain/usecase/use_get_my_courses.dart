import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final useGetMyCoursesProvider = Provider(
  (ref) => UseGetMyCourses(ref.read(coursesRepositoryProvider)),
);

class UseGetMyCourses {
  final ICoursesRepository _repository;

  const UseGetMyCourses(this._repository);

  Future<List<MyCourseEntity>> call() => _repository.getMyCourses();
}
