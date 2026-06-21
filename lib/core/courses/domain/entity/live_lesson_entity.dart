class LiveLessonEntity {
  final String id;
  final String title;
  final String videoPath;
  final String courseTitle;
  final String createdAt;

  const LiveLessonEntity({
    required this.id,
    required this.title,
    required this.videoPath,
    required this.courseTitle,
    required this.createdAt,
  });
}
