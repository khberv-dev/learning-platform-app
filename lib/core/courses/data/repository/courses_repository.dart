import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/courses/data/model/course_detail_response.dart';
import 'package:student/core/courses/data/model/course_response.dart';
import 'package:student/core/courses/data/model/lesson_detail_response.dart';
import 'package:student/core/courses/data/model/lesson_response.dart';
import 'package:student/core/courses/data/model/live_lesson_response.dart';
import 'package:student/core/courses/data/model/my_course_response.dart';
import 'package:student/core/courses/data/model/task_response.dart';
import 'package:student/core/courses/data/model/task_submission_result_response.dart';
import 'package:student/core/courses/data/model/unit_response.dart';
import 'package:student/core/courses/domain/entity/course_detail_entity.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_detail_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/domain/entity/task_entity.dart';
import 'package:student/core/courses/domain/entity/task_submission_result_entity.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final coursesRepositoryProvider = Provider<ICoursesRepository>(
  (ref) => CoursesRepository(dio: ref.read(dioClientProvider)),
);

class CoursesRepository implements ICoursesRepository {
  final Dio _dio;

  const CoursesRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<CourseEntity>> getAvailable() async {
    final response = await _dio.get(
      'student/courses/available',
      queryParameters: {'limit': 100},
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List<dynamic>;
    return list
        .map(
          (e) => CourseResponse.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<List<MyCourseEntity>> getMyCourses() async {
    final response = await _dio.get(
      'student/courses/me',
      queryParameters: {'limit': 100},
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List<dynamic>;
    return list
        .map(
          (e) =>
              MyCourseResponse.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<List<LiveLessonEntity>> getLiveLessons() async {
    final response = await _dio.get('student/live-lesson-recordings/my');
    final list = response.data as List<dynamic>;
    return list
        .map(
          (e) =>
              LiveLessonResponse.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<CourseDetailEntity> getCourseDetail(String id) async {
    final response = await _dio.get('student/courses/$id');
    return CourseDetailResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }

  @override
  Future<List<UnitEntity>> getUnits(String courseId) async {
    final response = await _dio.get(
      'student/courses/$courseId/units',
      queryParameters: {'limit': 100},
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List<dynamic>;
    return list
        .map((e) => UnitResponse.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<LessonEntity>> getLessons({
    required String courseId,
    required String unitId,
  }) async {
    final response = await _dio.get(
      'student/courses/$courseId/units/$unitId/lessons',
      queryParameters: {'limit': 100},
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List<dynamic>;
    return list
        .map(
          (e) => LessonResponse.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<LessonDetailEntity> getLessonDetail({
    required String courseId,
    required String unitId,
    required String lessonId,
  }) async {
    final response = await _dio.get(
      'student/courses/$courseId/units/$unitId/lessons/$lessonId',
    );
    return LessonDetailResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }

  @override
  Future<List<TaskEntity>> getTasks({
    required String courseId,
    required String unitId,
    required String lessonId,
  }) async {
    final response = await _dio.get(
      'student/courses/$courseId/units/$unitId/lessons/$lessonId/tasks',
      queryParameters: {'limit': 100},
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List<dynamic>;
    return list
        .map((e) => TaskResponse.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<TaskSubmissionResultEntity>> submitTasks(
    Map<String, List<String>> answers,
  ) async {
    // One answer string per question of the task, in question order.
    final response = await _dio.post('student/task-submissions', data: answers);
    final list = response.data as List<dynamic>;
    return list
        .map(
          (e) => TaskSubmissionResultResponse.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList();
  }
}
