import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final useSubmitTasksProvider = Provider(
  (ref) => UseSubmitTasks(ref.read(coursesRepositoryProvider)),
);

class UseSubmitTasks {
  final ICoursesRepository _repository;

  const UseSubmitTasks(this._repository);

  Future<void> call(Map<String, String> answers) =>
      _repository.submitTasks(answers);
}
