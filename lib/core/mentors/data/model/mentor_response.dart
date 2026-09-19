import 'package:student/core/mentors/domain/entity/mentor_entity.dart';

class MentorResponse {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? introVideo;
  final String? profession;
  final double rating;
  final String status;
  final Map<String, List<String>> schedule;

  const MentorResponse({
    required this.id,
    required this.name,
    required this.rating,
    required this.status,
    this.avatarUrl,
    this.introVideo,
    this.profession,
    this.schedule = const {},
  });

  // Flat on the wire — firstName/lastName/avatar sit directly on the mentor,
  // not under a nested `user` object. The list endpoint no longer returns a
  // feedback count, only the pre-averaged `summaryRating`.
  factory MentorResponse.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    final rawSchedule = json['schedule'] as Map<String, dynamic>? ?? {};

    return MentorResponse(
      id: json['id'].toString(),
      name: name.isEmpty ? 'Unknown' : name,
      avatarUrl: json['avatar'] as String?,
      introVideo: json['introVideo'] as String?,
      profession: json['profession'] as String?,
      rating: (json['summaryRating'] ?? 0).toDouble(),
      status: json['status'] as String? ?? 'active',
      schedule: rawSchedule.map(
        (day, slots) => MapEntry(day, List<String>.from(slots as List)),
      ),
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
    schedule: schedule,
  );
}
