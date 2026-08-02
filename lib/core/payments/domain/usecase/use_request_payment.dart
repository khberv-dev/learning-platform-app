import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/payments/data/repository/payments_repository.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/core/payments/domain/repository/i_payments_repository.dart';

final useRequestPaymentProvider = Provider<UseRequestPayment>(
  (ref) => UseRequestPayment(ref.read(paymentsRepositoryProvider)),
);

class UseRequestPayment {
  final IPaymentsRepository _repo;

  const UseRequestPayment(this._repo);

  Future<PaymentRequestEntity> call(String courseId) =>
      _repo.requestPayment(courseId);
}
