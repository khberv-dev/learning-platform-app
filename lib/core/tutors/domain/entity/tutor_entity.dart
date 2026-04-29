class TutorEntity {
  final String id;
  final String name;
  final String? avatarUrl;
  final double rating;
  final int feedbackCount;
  final String status;

  const TutorEntity({
    required this.id,
    required this.name,
    required this.rating,
    required this.feedbackCount,
    required this.status,
    this.avatarUrl,
  });

  bool get isActive => status == 'active';
}
