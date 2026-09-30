import 'package:student/core/courses/domain/entity/course_author_entity.dart';

class CourseDetailEntity {
  final String id;
  final String title;
  final String? description;
  final String? image;

  /// 0-100. Always 0 for a course the student hasn't enrolled in.
  final int totalProgress;

  final DateTime? announcedAt;

  /// Who made the course. Empty when the API credits no one.
  final List<CourseAuthorEntity> authors;

  const CourseDetailEntity({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.totalProgress = 0,
    this.announcedAt,
    this.authors = const [],
  });
}
