import 'package:student/core/assignments/domain/entity/assignment_entity.dart';

class AssignmentResponse {
  final String id;
  final String status;
  final String startDate;
  final Map<String, dynamic>? mentor;
  final Map<String, dynamic>? student;

  const AssignmentResponse({
    required this.id,
    required this.status,
    required this.startDate,
    this.mentor,
    this.student,
  });

  factory AssignmentResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      startDate: json['startDate'] as String,
      mentor: json['mentor'] as Map<String, dynamic>?,
      student: json['student'] as Map<String, dynamic>?,
    );
  }

  AssignmentEntity toEntity() {
    return AssignmentEntity(
      id: id,
      status: status,
      startDate: DateTime.parse(startDate),
      mentorId: mentor?['id'] as String? ?? '',
      studentId: student?['id'] as String? ?? '',
    );
  }
}
