import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/entity/task_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final useGetTasksProvider = Provider(
  (ref) => UseGetTasks(ref.read(coursesRepositoryProvider)),
);

class UseGetTasks {
  final ICoursesRepository _repository;

  const UseGetTasks(this._repository);

  Future<List<TaskEntity>> call({
    required String courseId,
    required String unitId,
    required String lessonId,
  }) => _repository.getTasks(
    courseId: courseId,
    unitId: unitId,
    lessonId: lessonId,
  );
}
