class MyCourseEntity {
  final String id;
  final String title;
  final int lessonsCount;
  final String level;
  final String? imageUrl;
  final double progress;

  const MyCourseEntity({
    required this.id,
    required this.title,
    required this.lessonsCount,
    required this.level,
    required this.progress,
    this.imageUrl,
  });
}
