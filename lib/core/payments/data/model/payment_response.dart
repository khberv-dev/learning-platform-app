import 'package:student/core/payments/data/model/payment_type_response.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';

class PaymentResponse {
  final String id;
  final String? status;
  final int amount;
  final String? planTitle;
  final String? courseTitle;
  final String createdAt;
  final PaymentTypeResponse? paymentType;

  const PaymentResponse({
    required this.id,
    this.status,
    this.amount = 0,
    this.planTitle,
    this.courseTitle,
    this.createdAt = '',
    this.paymentType,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    final type = json['paymentType'] as Map<String, dynamic>?;
    // A payment carries no direct plan/enrolment relation anymore — the path
    // to what it bought is purchases[0].subscription.plan(.course).
    final purchases = json['purchases'] as List<dynamic>? ?? const [];
    final subscription = purchases.isNotEmpty
        ? purchases.first['subscription'] as Map<String, dynamic>?
        : null;
    final plan = subscription?['plan'] as Map<String, dynamic>?;
    final course = plan?['course'] as Map<String, dynamic>?;
    return PaymentResponse(
      id: json['id'].toString(),
      status: json['status'] as String?,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      planTitle: plan?['title'] as String?,
      courseTitle: course?['title'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      paymentType: type == null ? null : PaymentTypeResponse.fromJson(type),
    );
  }

  PaymentEntity toEntity() => PaymentEntity(
    id: id,
    status: PaymentStatus.parse(status),
    amount: amount,
    planTitle: planTitle,
    courseTitle: courseTitle,
    createdAt: createdAt,
    paymentType: paymentType?.toEntity(),
  );
}

class PaymentRequestResponse {
  final PaymentResponse payment;
  final List<PaymentTypeResponse> paymentTypes;

  const PaymentRequestResponse({
    required this.payment,
    required this.paymentTypes,
  });

  factory PaymentRequestResponse.fromJson(Map<String, dynamic> json) {
    final types = (json['paymentTypes'] as List<dynamic>? ?? const [])
        .map((e) => PaymentTypeResponse.fromJson(e as Map<String, dynamic>))
        .toList();
    return PaymentRequestResponse(
      payment: PaymentResponse.fromJson(
        json['payment'] as Map<String, dynamic>,
      ),
      paymentTypes: types,
    );
  }

  PaymentRequestEntity toEntity() => PaymentRequestEntity(
    payment: payment.toEntity(),
    paymentTypes: paymentTypes.map((e) => e.toEntity()).toList(),
  );
}
