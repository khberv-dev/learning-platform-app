import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/payments/data/model/payment_response.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/core/payments/domain/repository/i_payments_repository.dart';

final paymentsRepositoryProvider = Provider<IPaymentsRepository>(
  (ref) => PaymentsRepository(dio: ref.read(dioClientProvider)),
);

/// Buying a course is a three-step handshake: request a payment, attach a
/// method, then settle with that provider outside the app. An admin confirms
/// it afterwards, which is what flips the enrolment to active.
class PaymentsRepository implements IPaymentsRepository {
  final Dio _dio;

  const PaymentsRepository({required Dio dio}) : _dio = dio;

  @override
  Future<PaymentRequestEntity> requestPayment(String courseId) async {
    final response = await _dio.post(
      'payments/request',
      data: {'courseId': courseId},
    );
    return PaymentRequestResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }

  @override
  Future<PaymentEntity> selectPaymentType({
    required String paymentId,
    required String paymentTypeId,
  }) async {
    final response = await _dio.patch(
      'payments/$paymentId/payment-type',
      data: {'paymentTypeId': paymentTypeId},
    );
    return PaymentResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }
}
