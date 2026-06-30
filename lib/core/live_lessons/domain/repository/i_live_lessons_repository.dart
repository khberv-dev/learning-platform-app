import 'package:student/core/live_lessons/domain/entity/live_lesson_scheduled_entity.dart';

abstract interface class ILiveLessonsRepository {
  Future<List<LiveLessonScheduledEntity>> getMyLessons();
}
