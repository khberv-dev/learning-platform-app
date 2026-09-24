import 'package:student/core/courses/domain/entity/course_entity.dart';

class CourseResponse {
  final String id;
  final String title;
  final String? imageUrl;
  final int totalProgress;
  final DateTime? announcedAt;

  const CourseResponse({
    required this.id,
    required this.title,
    this.imageUrl,
    this.totalProgress = 0,
    this.announcedAt,
  });

  factory CourseResponse.fromJson(Map<String, dynamic> json) => CourseResponse(
    id: json['id'].toString(),
    title: json['title'] as String,
    imageUrl: (json['imageUrl'] ?? json['image']) as String?,
    totalProgress: (json['totalProgress'] as num?)?.toInt() ?? 0,
    announcedAt: DateTime.tryParse(json['announcedAt'] as String? ?? ''),
  );

  CourseEntity toEntity() => CourseEntity(
    id: id,
    title: title,
    imageUrl: imageUrl,
    totalProgress: totalProgress,
    announcedAt: announcedAt,
  );
}
