import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/data/repository/courses_repository.dart';
import 'package:student/core/courses/domain/entity/lesson_material_entity.dart';
import 'package:student/core/courses/domain/repository/i_courses_repository.dart';

final useGetLessonMaterialsProvider = Provider(
  (ref) => UseGetLessonMaterials(ref.read(coursesRepositoryProvider)),
);

class UseGetLessonMaterials {
  final ICoursesRepository _repository;

  const UseGetLessonMaterials(this._repository);

  Future<List<LessonMaterialEntity>> call(String lessonId) =>
      _repository.getLessonMaterials(lessonId);
}
