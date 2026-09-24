import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/entity/lesson_detail_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final useGetLessonDetailProvider = Provider(
  (ref) => UseGetLessonDetail(ref.read(coursesRepositoryProvider)),
);

class UseGetLessonDetail {
  final ICoursesRepository _repository;

  const UseGetLessonDetail(this._repository);

  Future<LessonDetailEntity> call({
    required String courseId,
    required String unitId,
    required String lessonId,
  }) => _repository.getLessonDetail(
    courseId: courseId,
    unitId: unitId,
    lessonId: lessonId,
  );
}
