import 'package:student/core/courses/domain/entity/lesson_material_entity.dart';

/// How far a student has gotten through a lesson's tasks, as computed by the
/// API — never derived client-side.
class TaskProgressionEntity {
  final int totalTasks;
  final int completedTasks;

  /// 0-100.
  final int progressPercent;

  const TaskProgressionEntity({
    required this.totalTasks,
    required this.completedTasks,
    required this.progressPercent,
  });
}

/// A single lesson's content, from
/// `GET courses/:courseId/units/:unitId/lessons/:lessonId`. Carries its own
/// materials and task progress, unlike the leaner [LessonEntity] used for the
/// unit's lesson list.
class LessonDetailEntity {
  final String id;
  final String title;
  final String? description;
  final String? mediaUrl;
  final TaskProgressionEntity taskProgression;
  final List<LessonMaterialEntity> materials;

  const LessonDetailEntity({
    required this.id,
    required this.title,
    required this.taskProgression,
    this.description,
    this.mediaUrl,
    this.materials = const [],
  });
}
