import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/domain/usecase/use_get_available_courses.dart';
import 'package:student/core/courses/domain/usecase/use_get_live_lessons.dart';
import 'package:student/core/courses/domain/usecase/use_get_my_courses.dart';

final availableCoursesControllerProvider =
    AsyncNotifierProvider<AvailableCoursesController, List<CourseEntity>>(
      AvailableCoursesController.new,
    );

class AvailableCoursesController extends AsyncNotifier<List<CourseEntity>> {
  @override
  FutureOr<List<CourseEntity>> build() =>
      ref.read(useGetAvailableCoursesProvider).call();
}

final myCoursesControllerProvider =
    AsyncNotifierProvider<MyCoursesController, List<MyCourseEntity>>(
      MyCoursesController.new,
    );

class MyCoursesController extends AsyncNotifier<List<MyCourseEntity>> {
  @override
  FutureOr<List<MyCourseEntity>> build() =>
      ref.read(useGetMyCoursesProvider).call();
}

final liveLessonsControllerProvider =
    AsyncNotifierProvider<LiveLessonsController, List<LiveLessonEntity>>(
      LiveLessonsController.new,
    );

class LiveLessonsController extends AsyncNotifier<List<LiveLessonEntity>> {
  @override
  FutureOr<List<LiveLessonEntity>> build() =>
      ref.read(useGetLiveLessonsProvider).call();
}
