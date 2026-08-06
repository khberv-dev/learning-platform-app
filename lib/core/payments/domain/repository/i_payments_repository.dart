import 'package:student/core/payments/domain/entity/payment_entity.dart';

abstract class IPaymentsRepository {
  /// Opens a payment for [planId], creating the pending enrolment and
  /// payment. The API derives the course from the plan. Idempotent — an
  /// existing pending payment is reused, re-pointed at this plan if it differs.
  Future<PaymentRequestEntity> requestPayment(String planId);

  /// Attaches the student's chosen method, returning the payment with its
  /// `paymentType` filled in so the caller can open that provider.
  Future<PaymentEntity> selectPaymentType({
    required String paymentId,
    required String paymentTypeId,
  });
}
