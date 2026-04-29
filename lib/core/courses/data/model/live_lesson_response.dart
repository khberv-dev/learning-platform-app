import 'package:student/core/courses/domain/entity/live_lesson_entity.dart';

class LiveLessonResponse {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final String instructorName;
  final String duration;
  final String date;

  const LiveLessonResponse({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.instructorName,
    required this.duration,
    required this.date,
  });

  factory LiveLessonResponse.fromJson(Map<String, dynamic> json) {
    return LiveLessonResponse(
      id: json['id'].toString(),
      title: json['title'] as String,
      thumbnailUrl:
          json['thumbnailUrl'] as String? ?? json['thumbnail_url'] as String?,
      instructorName:
          json['instructorName'] as String? ??
          json['instructor_name'] as String? ??
          '',
      duration: json['duration'] as String? ?? '',
      date: json['date'] as String? ?? json['recordedAt'] as String? ?? '',
    );
  }

  LiveLessonEntity toEntity() => LiveLessonEntity(
    id: id,
    title: title,
    thumbnailUrl: thumbnailUrl,
    instructorName: instructorName,
    duration: duration,
    date: date,
  );
}
