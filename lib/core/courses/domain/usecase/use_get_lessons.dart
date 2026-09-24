import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final useGetLessonsProvider = Provider(
  (ref) => UseGetLessons(ref.read(coursesRepositoryProvider)),
);

class UseGetLessons {
  final ICoursesRepository _repository;

  const UseGetLessons(this._repository);

  Future<List<LessonEntity>> call({
    required String courseId,
    required String unitId,
  }) => _repository.getLessons(courseId: courseId, unitId: unitId);
}
