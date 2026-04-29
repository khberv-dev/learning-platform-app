import 'package:student/core/courses/domain/entity/my_course_entity.dart';

class MyCourseResponse {
  final String id;
  final String title;
  final int lessonsCount;
  final String level;
  final String? imageUrl;
  final double progress;

  const MyCourseResponse({
    required this.id,
    required this.title,
    required this.lessonsCount,
    required this.level,
    required this.progress,
    this.imageUrl,
  });

  factory MyCourseResponse.fromJson(Map<String, dynamic> json) {
    final rawProgress = (json['progress'] ?? 0) as num;
    // Normalise to 0.0–1.0 regardless of whether API returns 65 or 0.65.
    final progress = rawProgress > 1 ? rawProgress / 100 : rawProgress;

    return MyCourseResponse(
      id: json['id'] as String,
      title: json['title'] as String,
      lessonsCount:
          (json['lessonsCount'] ?? json['lessons_count'] ?? 0) as int,
      level: (json['level'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? json['image']) as String?,
      progress: progress.toDouble(),
    );
  }

  MyCourseEntity toEntity() => MyCourseEntity(
    id: id,
    title: title,
    lessonsCount: lessonsCount,
    level: level,
    imageUrl: imageUrl,
    progress: progress,
  );
}
