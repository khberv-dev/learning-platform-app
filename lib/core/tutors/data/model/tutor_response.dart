import 'package:student/core/tutors/domain/entity/tutor_entity.dart';

class TutorResponse {
  final String id;
  final String name;
  final String? avatarUrl;
  final String subject;
  final double rating;
  final int studentCount;
  final int pricePerHour;
  final bool isFeatured;

  const TutorResponse({
    required this.id,
    required this.name,
    required this.subject,
    required this.rating,
    required this.studentCount,
    required this.pricePerHour,
    required this.isFeatured,
    this.avatarUrl,
  });

  factory TutorResponse.fromJson(Map<String, dynamic> json) => TutorResponse(
        id: json['id'].toString(),
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] as String? ??
            json['avatar_url'] as String? ??
            json['avatar'] as String?,
        subject: json['subject'] as String? ?? '',
        rating: (json['rating'] ?? 0).toDouble(),
        studentCount:
            (json['studentCount'] ?? json['student_count'] ?? 0) as int,
        pricePerHour:
            (json['pricePerHour'] ?? json['price_per_hour'] ?? json['price'] ?? 0)
                as int,
        isFeatured:
            json['isFeatured'] as bool? ?? json['is_featured'] as bool? ?? false,
      );

  TutorEntity toEntity() => TutorEntity(
        id: id,
        name: name,
        avatarUrl: avatarUrl,
        subject: subject,
        rating: rating,
        studentCount: studentCount,
        pricePerHour: pricePerHour,
        isFeatured: isFeatured,
      );
}
