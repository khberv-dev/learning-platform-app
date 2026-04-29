class LessonEntity {
  final String id;
  final String title;
  final String? description;
  final String? mediaUrl;

  const LessonEntity({
    required this.id,
    required this.title,
    this.description,
    this.mediaUrl,
  });
}
