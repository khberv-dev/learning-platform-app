import 'package:student/core/payments/domain/entity/payment_entity.dart';

abstract class IPaymentsRepository {
  /// Opens a payment for [courseId], creating the pending enrolment and
  /// payment. Idempotent — an existing pending pair is returned as-is.
  Future<PaymentRequestEntity> requestPayment(String courseId);

  /// Attaches the student's chosen method, returning the payment with its
  /// `paymentType` filled in so the caller can open that provider.
  Future<PaymentEntity> selectPaymentType({
    required String paymentId,
    required String paymentTypeId,
  });
}
