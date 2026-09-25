import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/domain/entity/course_detail_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_detail_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';
import 'package:student/core/courses/domain/usecase/use_get_course_detail.dart';
import 'package:student/core/courses/domain/usecase/use_get_lesson_detail.dart';
import 'package:student/core/courses/domain/usecase/use_get_lessons.dart';
import 'package:student/core/courses/domain/usecase/use_get_units.dart';

// autoDispose throughout: each of these backs a screen reached by pushing a
// route, so the instance is torn down on pop and the next push starts a
// fresh fetch — course/unit/lesson data is never served stale from a
// previous visit.
final courseDetailControllerProvider = FutureProvider.autoDispose
    .family<CourseDetailEntity, String>(
      (ref, id) => ref.read(useGetCourseDetailProvider).call(id),
    );

final courseUnitsProvider = FutureProvider.autoDispose
    .family<List<UnitEntity>, String>(
      (ref, courseId) => ref.read(useGetUnitsProvider).call(courseId),
    );

typedef UnitLessonsParams = ({String courseId, String unitId});

final unitLessonsProvider = FutureProvider.autoDispose
    .family<List<LessonEntity>, UnitLessonsParams>(
      (ref, params) => ref
          .read(useGetLessonsProvider)
          .call(courseId: params.courseId, unitId: params.unitId),
    );

typedef LessonDetailParams = ({
  String courseId,
  String unitId,
  String lessonId,
});

final lessonDetailProvider = FutureProvider.autoDispose
    .family<LessonDetailEntity, LessonDetailParams>(
      (ref, params) => ref
          .read(useGetLessonDetailProvider)
          .call(
            courseId: params.courseId,
            unitId: params.unitId,
            lessonId: params.lessonId,
          ),
    );
