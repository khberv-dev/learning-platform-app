import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/live_lessons/data/repository/live_lessons_repository.dart';
import 'package:student/core/live_lessons/domain/entity/live_lesson_scheduled_entity.dart';
import 'package:student/core/live_lessons/domain/repository/i_live_lessons_repository.dart';

final useGetMyLiveLessonsProvider = Provider<UseGetMyLiveLessons>(
  (ref) => UseGetMyLiveLessons(ref.read(liveLessonsRepositoryProvider)),
);

class UseGetMyLiveLessons {
  final ILiveLessonsRepository _repo;

  const UseGetMyLiveLessons(this._repo);

  Future<List<LiveLessonScheduledEntity>> call() => _repo.getMyLessons();
}
