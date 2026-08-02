import 'package:student/core/payments/data/model/payment_type_response.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';

class PaymentEnrollmentResponse {
  final String id;
  final String? status;
  final String? start;
  final String? end;
  final String? courseTitle;

  const PaymentEnrollmentResponse({
    required this.id,
    this.status,
    this.start,
    this.end,
    this.courseTitle,
  });

  factory PaymentEnrollmentResponse.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>?;
    return PaymentEnrollmentResponse(
      id: json['id'].toString(),
      status: json['status'] as String?,
      start: json['start'] as String?,
      end: json['end'] as String?,
      courseTitle: course?['title'] as String?,
    );
  }

  PaymentEnrollmentEntity toEntity() => PaymentEnrollmentEntity(
    id: id,
    status: PaymentEnrollmentStatus.parse(status),
    start: start == null ? null : DateTime.tryParse(start!),
    end: end == null ? null : DateTime.tryParse(end!),
    courseTitle: courseTitle,
  );
}

class PaymentResponse {
  final String id;
  final String? status;
  final PaymentTypeResponse? paymentType;
  final PaymentEnrollmentResponse? enrollment;

  const PaymentResponse({
    required this.id,
    this.status,
    this.paymentType,
    this.enrollment,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    final type = json['paymentType'] as Map<String, dynamic>?;
    final enrollment = json['enrollment'] as Map<String, dynamic>?;
    return PaymentResponse(
      id: json['id'].toString(),
      status: json['status'] as String?,
      paymentType: type == null ? null : PaymentTypeResponse.fromJson(type),
      enrollment: enrollment == null
          ? null
          : PaymentEnrollmentResponse.fromJson(enrollment),
    );
  }

  PaymentEntity toEntity() => PaymentEntity(
    id: id,
    status: PaymentStatus.parse(status),
    paymentType: paymentType?.toEntity(),
    enrollment: enrollment?.toEntity(),
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
