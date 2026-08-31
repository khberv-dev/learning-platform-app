class LessonEntity {
  final String id;
  final String title;
  final String? description;
  final String? mediaUrl;
  final bool isLocked;

  const LessonEntity({
    required this.id,
    required this.title,
    this.description,
    this.mediaUrl,
    this.isLocked = false,
  });
}
