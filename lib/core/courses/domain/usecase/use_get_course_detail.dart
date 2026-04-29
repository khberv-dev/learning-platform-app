import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/entity/course_detail_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final useGetCourseDetailProvider = Provider<UseGetCourseDetail>(
  (ref) => UseGetCourseDetail(ref.read(coursesRepositoryProvider)),
);

class UseGetCourseDetail {
  final ICoursesRepository _repository;

  const UseGetCourseDetail(this._repository);

  Future<CourseDetailEntity> call(String id) => _repository.getCourseDetail(id);
}
