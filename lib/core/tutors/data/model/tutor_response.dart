import 'package:student/core/tutors/domain/entity/tutor_entity.dart';

class TutorResponse {
  final String id;
  final String name;
  final String? avatarUrl;
  final double rating;
  final int feedbackCount;
  final String status;

  const TutorResponse({
    required this.id,
    required this.name,
    required this.rating,
    required this.feedbackCount,
    required this.status,
    this.avatarUrl,
  });

  factory TutorResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final firstName = user['firstName'] as String? ?? '';
    final lastName = user['lastName'] as String? ?? '';
    final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    final feedbacks = json['feedbacks'] as List<dynamic>? ?? [];

    return TutorResponse(
      id: json['id'].toString(),
      name: name.isEmpty ? 'Unknown' : name,
      avatarUrl: user['avatar'] as String?,
      rating: (json['summaryRating'] ?? 0).toDouble(),
      feedbackCount: feedbacks.length,
      status: json['status'] as String? ?? 'active',
    );
  }

  TutorEntity toEntity() => TutorEntity(
        id: id,
        name: name,
        avatarUrl: avatarUrl,
        rating: rating,
        feedbackCount: feedbackCount,
        status: status,
      );
}
