import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/payments/data/repository/payments_repository.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/core/payments/domain/repository/i_payments_repository.dart';

final useSelectPaymentTypeProvider = Provider<UseSelectPaymentType>(
  (ref) => UseSelectPaymentType(ref.read(paymentsRepositoryProvider)),
);

class UseSelectPaymentType {
  final IPaymentsRepository _repo;

  const UseSelectPaymentType(this._repo);

  Future<PaymentEntity> call({
    required String paymentId,
    required String paymentTypeId,
  }) => _repo.selectPaymentType(
    paymentId: paymentId,
    paymentTypeId: paymentTypeId,
  );
}
