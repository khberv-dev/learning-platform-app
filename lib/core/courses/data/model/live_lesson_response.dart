import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';

class LiveLessonResponse {
  final String id;
  final String title;
  final String videoPath;
  final String mentorName;
  final String createdAt;

  const LiveLessonResponse({
    required this.id,
    required this.title,
    required this.videoPath,
    required this.mentorName,
    required this.createdAt,
  });

  factory LiveLessonResponse.fromJson(Map<String, dynamic> json) {
    final assignment = json['assignment'] as Map<String, dynamic>?;
    final teacher = assignment?['teacher'] as Map<String, dynamic>?;
    final user = teacher?['user'] as Map<String, dynamic>?;
    final firstName = user?['firstName'] as String? ?? '';
    final lastName = user?['lastName'] as String? ?? '';
    final mentorName = [
      firstName,
      lastName,
    ].where((s) => s.isNotEmpty).join(' ');

    return LiveLessonResponse(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      videoPath: json['videoPath'] as String? ?? '',
      mentorName: mentorName,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  LiveLessonEntity toEntity() => LiveLessonEntity(
    id: id,
    title: title,
    videoPath: videoPath,
    mentorName: mentorName,
    createdAt: createdAt,
  );
}
