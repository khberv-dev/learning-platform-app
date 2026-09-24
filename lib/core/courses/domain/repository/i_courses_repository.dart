import 'package:student/core/courses/domain/entity/course_detail_entity.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_detail_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/domain/entity/task_entity.dart';
import 'package:student/core/courses/domain/entity/task_submission_result_entity.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';

abstract class ICoursesRepository {
  Future<List<CourseEntity>> getAvailable();

  Future<List<MyCourseEntity>> getMyCourses();

  Future<List<LiveLessonEntity>> getLiveLessons();

  Future<CourseDetailEntity> getCourseDetail(String id);

  Future<List<UnitEntity>> getUnits(String courseId);

  Future<List<LessonEntity>> getLessons({
    required String courseId,
    required String unitId,
  });

  Future<LessonDetailEntity> getLessonDetail({
    required String courseId,
    required String unitId,
    required String lessonId,
  });

  Future<List<TaskEntity>> getTasks({
    required String courseId,
    required String unitId,
    required String lessonId,
  });

  Future<List<TaskSubmissionResultEntity>> submitTasks(
    Map<String, List<String>> answers,
  );
}
