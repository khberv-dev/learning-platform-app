import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';

class LiveLessonResponse {
  final String id;
  final String title;
  final String videoPath;
  final String groupTitle;
  final String createdAt;

  const LiveLessonResponse({
    required this.id,
    required this.title,
    required this.videoPath,
    required this.groupTitle,
    required this.createdAt,
  });

  factory LiveLessonResponse.fromJson(Map<String, dynamic> json) {
    final group = json['group'] as Map<String, dynamic>?;

    return LiveLessonResponse(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      videoPath: json['videoUrl'] as String? ?? '',
      groupTitle: group?['title'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  LiveLessonEntity toEntity() => LiveLessonEntity(
    id: id,
    title: title,
    videoPath: videoPath,
    groupTitle: groupTitle,
    createdAt: createdAt,
  );
}
