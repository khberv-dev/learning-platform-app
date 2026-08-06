import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/core/payments/domain/usecase/use_request_payment.dart';

/// Opens (or reuses) the pending payment for a plan and carries the methods it
/// can be settled with — the request is idempotent, so re-reading this is
/// safe. Keyed by plan id.
final paymentRequestControllerProvider =
    FutureProvider.family<PaymentRequestEntity, String>(
      (ref, planId) => ref.read(useRequestPaymentProvider).call(planId),
    );
