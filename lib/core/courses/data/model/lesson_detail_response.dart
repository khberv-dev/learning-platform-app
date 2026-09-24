import 'package:student/core/courses/data/model/lesson_material_response.dart';
import 'package:student/core/courses/domain/entity/lesson_detail_entity.dart';

class TaskProgressionResponse {
  final int totalTasks;
  final int completedTasks;
  final int progressPercent;

  const TaskProgressionResponse({
    required this.totalTasks,
    required this.completedTasks,
    required this.progressPercent,
  });

  factory TaskProgressionResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TaskProgressionResponse(
        totalTasks: 0,
        completedTasks: 0,
        progressPercent: 0,
      );
    }
    return TaskProgressionResponse(
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
    );
  }

  TaskProgressionEntity toEntity() => TaskProgressionEntity(
    totalTasks: totalTasks,
    completedTasks: completedTasks,
    progressPercent: progressPercent,
  );
}

class LessonDetailResponse {
  final String id;
  final String title;
  final String? description;
  final String? mediaUrl;
  final TaskProgressionResponse taskProgression;
  final List<LessonMaterialResponse> materials;

  const LessonDetailResponse({
    required this.id,
    required this.title,
    required this.taskProgression,
    this.description,
    this.mediaUrl,
    this.materials = const [],
  });

  factory LessonDetailResponse.fromJson(Map<String, dynamic> json) {
    final rawMaterials = json['materials'] as List<dynamic>? ?? [];
    return LessonDetailResponse(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String?,
      mediaUrl: json['media'] as String? ?? json['mediaUrl'] as String?,
      taskProgression: TaskProgressionResponse.fromJson(
        json['taskProgression'] as Map<String, dynamic>?,
      ),
      materials: rawMaterials
          .map(
            (e) => LessonMaterialResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  LessonDetailEntity toEntity() => LessonDetailEntity(
    id: id,
    title: title,
    description: description,
    mediaUrl: mediaUrl,
    taskProgression: taskProgression.toEntity(),
    materials: materials.map((m) => m.toEntity()).toList(),
  );
}
