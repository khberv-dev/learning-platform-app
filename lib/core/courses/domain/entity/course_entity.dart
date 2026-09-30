class CourseEntity {
  final String id;
  final String title;
  final String? imageUrl;
  final String? description;

  /// 0-100. Always 0 for a course the student hasn't enrolled in.
  final int totalProgress;

  /// When the course was announced. Null for courses that predate the field.
  final DateTime? announcedAt;

  /// How many lessons the course has, and roughly how many hours it takes.
  /// Null when the API doesn't send them; the list then leaves the chip out.
  final int? lessonsCount;
  final int? durationHours;

  const CourseEntity({
    required this.id,
    required this.title,
    this.imageUrl,
    this.description,
    this.totalProgress = 0,
    this.announcedAt,
    this.lessonsCount,
    this.durationHours,
  });
}
