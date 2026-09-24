class CourseEntity {
  final String id;
  final String title;
  final String? imageUrl;

  /// 0-100. Always 0 for a course the student hasn't enrolled in.
  final int totalProgress;

  /// When the course was announced. Null for courses that predate the field.
  final DateTime? announcedAt;

  const CourseEntity({
    required this.id,
    required this.title,
    this.imageUrl,
    this.totalProgress = 0,
    this.announcedAt,
  });
}
