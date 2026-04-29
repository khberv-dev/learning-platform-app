class LiveLessonEntity {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final String instructorName;
  final String duration;
  final String date;

  const LiveLessonEntity({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.instructorName,
    required this.duration,
    required this.date,
  });
}
