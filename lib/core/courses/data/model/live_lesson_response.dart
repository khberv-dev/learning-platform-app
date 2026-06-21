import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';

class LiveLessonResponse {
  final String id;
  final String title;
  final String videoPath;
  final String courseTitle;
  final String createdAt;

  const LiveLessonResponse({
    required this.id,
    required this.title,
    required this.videoPath,
    required this.courseTitle,
    required this.createdAt,
  });

  factory LiveLessonResponse.fromJson(Map<String, dynamic> json) {
    final enrollment = json['enrollment'] as Map<String, dynamic>?;
    final course = enrollment?['course'] as Map<String, dynamic>?;

    return LiveLessonResponse(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      videoPath: json['videoPath'] as String? ?? '',
      courseTitle: course?['title'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  LiveLessonEntity toEntity() => LiveLessonEntity(
    id: id,
    title: title,
    videoPath: videoPath,
    courseTitle: courseTitle,
    createdAt: createdAt,
  );
}
