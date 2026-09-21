class LiveLessonEntity {
  final String id;
  final String title;
  final String videoPath;
  final String groupTitle;
  final String createdAt;

  const LiveLessonEntity({
    required this.id,
    required this.title,
    required this.videoPath,
    required this.groupTitle,
    required this.createdAt,
  });
}
