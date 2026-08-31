import 'package:student/core/courses/domain/entity/lesson_entity.dart';

class LessonResponse {
  final String id;
  final String title;
  final String? description;
  final String? mediaUrl;
  final bool isLocked;

  const LessonResponse({
    required this.id,
    required this.title,
    this.description,
    this.mediaUrl,
    this.isLocked = false,
  });

  factory LessonResponse.fromJson(Map<String, dynamic> json) => LessonResponse(
    id: json['id'].toString(),
    title: json['title'] as String,
    description: json['description'] as String?,
    mediaUrl: json['media'] as String? ?? json['mediaUrl'] as String?,
    isLocked: json['isLocked'] as bool? ?? false,
  );

  LessonEntity toEntity() => LessonEntity(
    id: id,
    title: title,
    description: description,
    mediaUrl: mediaUrl,
    isLocked: isLocked,
  );
}
