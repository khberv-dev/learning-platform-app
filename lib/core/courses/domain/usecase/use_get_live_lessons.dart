import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final useGetLiveLessonsProvider = Provider<UseGetLiveLessons>(
  (ref) => UseGetLiveLessons(ref.read(coursesRepositoryProvider)),
);

class UseGetLiveLessons {
  final ICoursesRepository _repository;

  const UseGetLiveLessons(this._repository);

  Future<List<LiveLessonEntity>> call() => _repository.getLiveLessons();
}
