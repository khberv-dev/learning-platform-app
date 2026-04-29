class TutorEntity {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? introVideo;
  final String? profession;
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
    this.introVideo,
    this.profession,
  });

  bool get isActive => status == 'active';
}
