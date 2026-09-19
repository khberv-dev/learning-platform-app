import 'package:student/core/enrollments/domain/entity/enrollment_history_entity.dart';

class EnrollmentHistoryResponse {
  final String id;
  final String purchaseAmount;
  final String? start;
  final String? end;
  final String courseTitle;
  final String? createdAt;

  const EnrollmentHistoryResponse({
    required this.id,
    required this.purchaseAmount,
    required this.courseTitle,
    this.start,
    this.end,
    this.createdAt,
  });

  factory EnrollmentHistoryResponse.fromJson(Map<String, dynamic> json) {
    final enrollment = json['enrollment'] as Map<String, dynamic>?;
    final course = enrollment?['course'] as Map<String, dynamic>?;
    return EnrollmentHistoryResponse(
      id: json['id'] as String,
      purchaseAmount: json['purchaseAmount']?.toString() ?? '0',
      start: json['start'] as String?,
      end: json['end'] as String?,
      courseTitle: course?['title'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );
  }

  EnrollmentHistoryEntity toEntity() => EnrollmentHistoryEntity(
    id: id,
    purchaseAmount: purchaseAmount,
    courseTitle: courseTitle,
    start: start == null ? null : DateTime.tryParse(start!),
    end: end == null ? null : DateTime.tryParse(end!),
    createdAt: createdAt == null ? null : DateTime.tryParse(createdAt!),
  );
}
