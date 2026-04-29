import 'package:student/core/courses/domain/entity/my_course_entity.dart';

class MyCourseResponse {
  final String enrollmentId;
  final String courseId;
  final String title;
  final int lessonsCount;
  final String? imageUrl;
  final double progress;
  final CourseStatus status;

  const MyCourseResponse({
    required this.enrollmentId,
    required this.courseId,
    required this.title,
    required this.lessonsCount,
    required this.progress,
    required this.status,
    this.imageUrl,
  });

  factory MyCourseResponse.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>;
    final rawProgress = (json['totalProgress'] ?? 0) as num;
    final progress = rawProgress > 1 ? rawProgress / 100 : rawProgress;

    final statusStr = json['status'] as String? ?? 'active';
    final status = statusStr == 'expired' ? CourseStatus.expired : CourseStatus.active;

    return MyCourseResponse(
      enrollmentId: json['id'].toString(),
      courseId: course['id'].toString(),
      title: course['title'] as String,
      lessonsCount: (json['lessonsCount'] ?? json['lessons_count'] ?? 0) as int,
      imageUrl: course['image'] as String?,
      progress: progress.toDouble(),
      status: status,
    );
  }

  MyCourseEntity toEntity() => MyCourseEntity(
        enrollmentId: enrollmentId,
        courseId: courseId,
        title: title,
        lessonsCount: lessonsCount,
        imageUrl: imageUrl,
        progress: progress,
        status: status,
      );
}
