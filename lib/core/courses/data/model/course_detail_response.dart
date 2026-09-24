import 'package:student/core/courses/domain/entity/course_detail_entity.dart';

class CourseDetailResponse {
  final String id;
  final String title;
  final String? description;
  final String? image;
  final int totalProgress;
  final DateTime? announcedAt;

  const CourseDetailResponse({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.totalProgress = 0,
    this.announcedAt,
  });

  factory CourseDetailResponse.fromJson(Map<String, dynamic> json) {
    return CourseDetailResponse(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      totalProgress: (json['totalProgress'] as num?)?.toInt() ?? 0,
      announcedAt: DateTime.tryParse(json['announcedAt'] as String? ?? ''),
    );
  }

  CourseDetailEntity toEntity() => CourseDetailEntity(
    id: id,
    title: title,
    description: description,
    image: image,
    totalProgress: totalProgress,
    announcedAt: announcedAt,
  );
}
