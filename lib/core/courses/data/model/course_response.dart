import 'package:student/core/courses/domain/entity/course_entity.dart';

class CourseResponse {
  final String id;
  final String title;
  final int lessonsCount;
  final String? imageUrl;
  final DateTime? announcedAt;

  const CourseResponse({
    required this.id,
    required this.title,
    required this.lessonsCount,
    this.imageUrl,
    this.announcedAt,
  });

  factory CourseResponse.fromJson(Map<String, dynamic> json) => CourseResponse(
    id: json['id'] as String,
    title: json['title'] as String,
    lessonsCount: (json['lessonsCount'] ?? json['lessons_count'] ?? 0) as int,
    imageUrl: (json['imageUrl'] ?? json['image']) as String?,
    announcedAt: DateTime.tryParse(json['announcedAt'] as String? ?? ''),
  );

  CourseEntity toEntity() => CourseEntity(
    id: id,
    title: title,
    lessonsCount: lessonsCount,
    imageUrl: imageUrl,
    announcedAt: announcedAt,
  );
}
