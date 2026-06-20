import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/entity/task_result_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final useGetLessonResultsProvider = Provider(
  (ref) => UseGetLessonResults(ref.read(coursesRepositoryProvider)),
);

class UseGetLessonResults {
  final ICoursesRepository _repository;

  const UseGetLessonResults(this._repository);

  Future<List<TaskResultEntity>> call(String lessonId) =>
      _repository.getLessonResults(lessonId);
}
