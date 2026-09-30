import 'package:student/core/courses/domain/entity/course_entity.dart';

class CourseResponse {
  final String id;
  final String title;
  final String? imageUrl;
  final String? description;
  final int totalProgress;
  final DateTime? announcedAt;
  final int? lessonsCount;
  final int? durationHours;

  const CourseResponse({
    required this.id,
    required this.title,
    this.imageUrl,
    this.description,
    this.totalProgress = 0,
    this.announcedAt,
    this.lessonsCount,
    this.durationHours,
  });

  factory CourseResponse.fromJson(Map<String, dynamic> json) => CourseResponse(
    id: json['id'].toString(),
    title: json['title'] as String,
    imageUrl: (json['imageUrl'] ?? json['image']) as String?,
    description: json['description'] as String?,
    totalProgress: (json['totalProgress'] as num?)?.toInt() ?? 0,
    announcedAt: DateTime.tryParse(json['announcedAt'] as String? ?? ''),
    // Not in the list response yet — read if and when the API adds them.
    lessonsCount: (json['lessonsCount'] as num?)?.toInt(),
    durationHours: (json['durationHours'] as num?)?.toInt(),
  );

  CourseEntity toEntity() => CourseEntity(
    id: id,
    title: title,
    imageUrl: imageUrl,
    description: description,
    totalProgress: totalProgress,
    announcedAt: announcedAt,
    lessonsCount: lessonsCount,
    durationHours: durationHours,
  );
}
