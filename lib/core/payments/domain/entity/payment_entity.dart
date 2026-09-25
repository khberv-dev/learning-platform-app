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

class PaymentEntity {
  final String id;
  final PaymentStatus status;
  final int amount;
  final String? planTitle;

  /// The course a settled payment's plan belongs to. Reached through
  /// `purchases[0].subscription.plan.course` on the wire — a payment no
  /// longer carries a direct enrolment relation.
  final String? courseTitle;

  final String createdAt;

  /// Null until the student picks a method.
  final PaymentTypeEntity? paymentType;

  const PaymentEntity({
    required this.id,
    required this.status,
    this.amount = 0,
    this.planTitle,
    this.courseTitle,
    this.createdAt = '',
    this.paymentType,
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

class PaymentsPageEntity {
  final List<PaymentEntity> payments;
  final int page;
  final int totalPages;

  const PaymentsPageEntity({
    required this.payments,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
