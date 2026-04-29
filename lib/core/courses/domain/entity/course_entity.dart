class CourseEntity {
  final String id;
  final String title;
  final int lessonsCount;
  final String level;
  final String? imageUrl;
  final int price;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.lessonsCount,
    required this.level,
    required this.price,
    this.imageUrl,
  });
}
