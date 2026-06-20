import 'package:student/core/courses/domain/entity/course_detail_entity.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/domain/entity/task_entity.dart';
import 'package:student/core/courses/domain/entity/task_result_entity.dart';

abstract class ICoursesRepository {
  Future<List<CourseEntity>> getAvailable();

  Future<List<MyCourseEntity>> getMyCourses();

  Future<List<LiveLessonEntity>> getLiveLessons();

  Future<CourseDetailEntity> getCourseDetail(String id);

  Future<List<TaskEntity>> getTasks({
    required String courseId,
    required String unitId,
    required String lessonId,
  });

  Future<void> submitTasks(Map<String, String> answers);

  Future<List<TaskResultEntity>> getLessonResults(String lessonId);
}
