import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/payments/data/repository/payments_repository.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/core/payments/domain/repository/i_payments_repository.dart';

final useGetMyPaymentsProvider = Provider<UseGetMyPayments>(
  (ref) => UseGetMyPayments(ref.read(paymentsRepositoryProvider)),
);

class UseGetMyPayments {
  final IPaymentsRepository _repo;

  const UseGetMyPayments(this._repo);

  Future<PaymentsPageEntity> call({required int page, int limit = 10}) =>
      _repo.getMyPayments(page: page, limit: limit);
}
