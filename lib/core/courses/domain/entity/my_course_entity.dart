enum CourseStatus { active, expired }

class MyCourseEntity {
  final String enrollmentId;
  final String courseId;
  final String title;
  final int lessonsCount;
  final String? imageUrl;
  final double progress;
  final CourseStatus status;

  const MyCourseEntity({
    required this.enrollmentId,
    required this.courseId,
    required this.title,
    required this.lessonsCount,
    required this.progress,
    required this.status,
    this.imageUrl,
  });
}
