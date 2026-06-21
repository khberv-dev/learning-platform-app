class AssignmentEntity {
  final String id;
  final String status;
  final DateTime startDate;
  final String teacherId;
  final String studentId;

  const AssignmentEntity({
    required this.id,
    required this.status,
    required this.startDate,
    required this.teacherId,
    required this.studentId,
  });
}
