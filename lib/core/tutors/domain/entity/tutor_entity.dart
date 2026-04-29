class TutorEntity {
  final String id;
  final String name;
  final String? avatarUrl;
  final String subject;
  final double rating;
  final int studentCount;
  final int pricePerHour;
  final bool isFeatured;

  const TutorEntity({
    required this.id,
    required this.name,
    required this.subject,
    required this.rating,
    required this.studentCount,
    required this.pricePerHour,
    required this.isFeatured,
    this.avatarUrl,
  });
}
