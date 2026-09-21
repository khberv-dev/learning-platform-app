class MentorEntity {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? introVideo;
  final String? profession;
  final double rating;
  final String status;

  const MentorEntity({
    required this.id,
    required this.name,
    required this.rating,
    required this.status,
    this.avatarUrl,
    this.introVideo,
    this.profession,
  });

  bool get isActive => status == 'active';
}
