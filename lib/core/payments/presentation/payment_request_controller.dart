import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/core/payments/domain/usecase/use_request_payment.dart';

/// Opens (or reuses) the pending payment for a course and carries the methods
/// it can be settled with — the request is idempotent, so re-reading this is
/// safe. Keyed by course id.
final paymentRequestControllerProvider =
    FutureProvider.family<PaymentRequestEntity, String>(
      (ref, courseId) => ref.read(useRequestPaymentProvider).call(courseId),
    );
