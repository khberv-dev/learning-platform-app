import 'package:student/core/courses/domain/entity/lesson_entity.dart';

class LessonResponse {
  final String id;
  final String title;
  final String? description;
  final bool isLocked;
  final Duration? duration;
  final int? progressPercent;

  const LessonResponse({
    required this.id,
    required this.title,
    this.description,
    this.isLocked = false,
    this.duration,
    this.progressPercent,
  });

  factory LessonResponse.fromJson(Map<String, dynamic> json) => LessonResponse(
    id: json['id'].toString(),
    title: json['title'] as String,
    description: json['description'] as String?,
    isLocked: json['isLocked'] as bool? ?? false,
    // Seconds, when the API sends it.
    duration: switch (json['duration']) {
      final num s => Duration(milliseconds: (s * 1000).round()),
      _ => null,
    },
    // Same shape as the lesson detail's, when the list carries it.
    progressPercent: switch (json['taskProgression']) {
      {'progressPercent': final num p} => p.toInt(),
      _ => (json['progressPercent'] as num?)?.toInt(),
    },
  );

  LessonEntity toEntity() => LessonEntity(
    id: id,
    title: title,
    description: description,
    isLocked: isLocked,
    duration: duration,
    progressPercent: progressPercent,
  );
}
