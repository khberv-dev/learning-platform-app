import 'package:student/core/courses/domain/entity/course_entity.dart';

class CourseResponse {
  final String id;
  final String title;
  final int lessonsCount;
  final String level;
  final String? imageUrl;
  final int price;

  const CourseResponse({
    required this.id,
    required this.title,
    required this.lessonsCount,
    required this.level,
    required this.price,
    this.imageUrl,
  });

  factory CourseResponse.fromJson(Map<String, dynamic> json) => CourseResponse(
    id: json['id'] as String,
    title: json['title'] as String,
    lessonsCount: (json['lessonsCount'] ?? json['lessons_count'] ?? 0) as int,
    level: (json['level'] ?? '') as String,
    imageUrl: (json['imageUrl'] ?? json['image']) as String?,
    price: (json['price'] ?? 0) as int,
  );

  CourseEntity toEntity() => CourseEntity(
    id: id,
    title: title,
    lessonsCount: lessonsCount,
    level: level,
    imageUrl: imageUrl,
    price: price,
  );
}
