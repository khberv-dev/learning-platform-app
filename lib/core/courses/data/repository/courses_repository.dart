import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/courses/data/model/course_response.dart';
import 'package:student/core/courses/data/model/live_lesson_response.dart';
import 'package:student/core/courses/data/model/my_course_response.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final coursesRepositoryProvider = Provider<ICoursesRepository>(
  (ref) => CoursesRepository(dio: ref.read(dioClientProvider)),
);

class CoursesRepository implements ICoursesRepository {
  final Dio _dio;

  const CoursesRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<CourseEntity>> getAvailable() async {
    final response = await _dio.get('courses/available');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => CourseResponse.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<MyCourseEntity>> getMyCourses() async {
    final response = await _dio.get('courses/me');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => MyCourseResponse.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<LiveLessonEntity>> getLiveLessons() async {
    final response = await _dio.get('live-sessions');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => LiveLessonResponse.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }
}
