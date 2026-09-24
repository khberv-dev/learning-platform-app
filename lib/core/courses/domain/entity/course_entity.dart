class CourseEntity {
  final String id;
  final String title;
  final int lessonsCount;
  final String? imageUrl;

  /// When the course was announced. Null for courses that predate the field.
  final DateTime? announcedAt;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.lessonsCount,
    this.imageUrl,
    this.announcedAt,
  });
}
