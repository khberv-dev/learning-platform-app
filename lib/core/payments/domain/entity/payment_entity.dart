import 'package:student/core/payments/domain/entity/payment_type_entity.dart';

enum PaymentStatus {
  /// Requested but not yet confirmed by an admin.
  created,
  paid,
  cancelled;

  static PaymentStatus parse(String? raw) => switch (raw) {
    'paid' => PaymentStatus.paid,
    'cancelled' => PaymentStatus.cancelled,
    _ => PaymentStatus.created,
  };

  bool get isSettled => this != PaymentStatus.created;
}

enum PaymentEnrollmentStatus {
  /// Awaiting payment — the course content stays locked.
  created,
  active,
  cancelled;

  static PaymentEnrollmentStatus parse(String? raw) => switch (raw) {
    'active' => PaymentEnrollmentStatus.active,
    'cancelled' => PaymentEnrollmentStatus.cancelled,
    _ => PaymentEnrollmentStatus.created,
  };
}

/// The enrolment a payment unlocks. `start` and `end` stay null until an admin
/// confirms the payment.
class PaymentEnrollmentEntity {
  final String id;
  final PaymentEnrollmentStatus status;
  final DateTime? start;
  final DateTime? end;
  final String? courseTitle;

  const PaymentEnrollmentEntity({
    required this.id,
    required this.status,
    this.start,
    this.end,
    this.courseTitle,
  });
}

class PaymentEntity {
  final String id;
  final PaymentStatus status;

  /// Null until the student picks a method.
  final PaymentTypeEntity? paymentType;

  final PaymentEnrollmentEntity? enrollment;

  const PaymentEntity({
    required this.id,
    required this.status,
    this.paymentType,
    this.enrollment,
  });
}

/// What `POST /payments/request` answers with: the pending payment plus the
/// methods it can be settled with. There is no standalone endpoint for the
/// latter — this is the only way a student sees them.
class PaymentRequestEntity {
  final PaymentEntity payment;
  final List<PaymentTypeEntity> paymentTypes;

  const PaymentRequestEntity({
    required this.payment,
    required this.paymentTypes,
  });
}
