import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/domain/entity/lesson_material_entity.dart';
import 'package:student/core/courses/domain/usecase/use_get_lesson_materials.dart';

/// Handouts attached to a lesson, keyed by lesson id.
final lessonMaterialsProvider =
    FutureProvider.family<List<LessonMaterialEntity>, String>(
      (ref, lessonId) => ref.read(useGetLessonMaterialsProvider).call(lessonId),
    );
