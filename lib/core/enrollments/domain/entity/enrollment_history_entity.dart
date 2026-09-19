/// One purchase term — an enrolment period the student paid for. Multiple
/// entries can point at the same course when it was bought more than once
/// (e.g. re-purchased after expiring).
class EnrollmentHistoryEntity {
  final String id;
  final String purchaseAmount;
  final DateTime? start;
  final DateTime? end;
  final String courseTitle;
  final DateTime? createdAt;

  const EnrollmentHistoryEntity({
    required this.id,
    required this.purchaseAmount,
    required this.courseTitle,
    this.start,
    this.end,
    this.createdAt,
  });
}
