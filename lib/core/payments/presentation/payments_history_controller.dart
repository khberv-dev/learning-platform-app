import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/core/payments/domain/usecase/use_get_my_payments.dart';

final paymentsHistoryControllerProvider =
    AsyncNotifierProvider<PaymentsHistoryController, List<PaymentEntity>>(
      PaymentsHistoryController.new,
    );

class PaymentsHistoryController extends AsyncNotifier<List<PaymentEntity>> {
  @override
  FutureOr<List<PaymentEntity>> build() async {
    final page = await ref
        .read(useGetMyPaymentsProvider)
        .call(page: 1, limit: 50);
    return page.payments;
  }
}
