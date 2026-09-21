import 'package:student/core/mentors/domain/entity/mentor_entity.dart';

class MentorResponse {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? introVideo;
  final String? profession;
  final double rating;
  final String status;

  const MentorResponse({
    required this.id,
    required this.name,
    required this.rating,
    required this.status,
    this.avatarUrl,
    this.introVideo,
    this.profession,
  });

  // Flat on the wire — firstName/lastName/avatar sit directly on the mentor,
  // not under a nested `user` object. The list endpoint no longer returns a
  // feedback count, only the pre-averaged `summaryRating`.
  factory MentorResponse.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    return MentorResponse(
      id: json['id'].toString(),
      name: name.isEmpty ? 'Unknown' : name,
      avatarUrl: json['avatar'] as String?,
      introVideo: json['introVideo'] as String?,
      profession: json['profession'] as String?,
      rating: (json['summaryRating'] ?? 0).toDouble(),
      status: json['status'] as String? ?? 'active',
    );
  }

  MentorEntity toEntity() => MentorEntity(
    id: id,
    name: name,
    avatarUrl: avatarUrl,
    introVideo: introVideo,
    profession: profession,
    rating: rating,
    status: status,
  );
}
