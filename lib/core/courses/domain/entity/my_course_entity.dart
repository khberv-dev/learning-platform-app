class MyCourseEntity {
  final String enrollmentId;
  final String courseId;
  final String title;
  final int lessonsCount;
  final String? imageUrl;
  final double progress;

  const MyCourseEntity({
    required this.enrollmentId,
    required this.courseId,
    required this.title,
    required this.lessonsCount,
    required this.progress,
    this.imageUrl,
  });
}
