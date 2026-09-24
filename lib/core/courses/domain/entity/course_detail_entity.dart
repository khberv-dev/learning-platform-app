class CourseDetailEntity {
  final String id;
  final String title;
  final String? description;
  final String? image;

  /// 0-100. Always 0 for a course the student hasn't enrolled in.
  final int totalProgress;

  final DateTime? announcedAt;

  const CourseDetailEntity({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.totalProgress = 0,
    this.announcedAt,
  });
}
