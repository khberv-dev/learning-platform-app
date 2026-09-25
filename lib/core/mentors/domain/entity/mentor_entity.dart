class MentorEntity {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? introVideo;
  final String? profession;
  final double rating;

  const MentorEntity({
    required this.id,
    required this.name,
    required this.rating,
    this.avatarUrl,
    this.introVideo,
    this.profession,
  });
}
