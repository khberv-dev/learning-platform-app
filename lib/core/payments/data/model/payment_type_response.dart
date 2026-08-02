import 'package:student/core/payments/domain/entity/payment_type_entity.dart';
import 'package:student/utils/lib.dart';

class PaymentTypeResponse {
  final String id;
  final String title;
  final String? icon;
  final String? url;

  const PaymentTypeResponse({
    required this.id,
    required this.title,
    this.icon,
    this.url,
  });

  /// Tolerant of the field names the endpoint might land on — `title`/`name`
  /// and `icon`/`logo`/`image` are all plausible.
  factory PaymentTypeResponse.fromJson(Map<String, dynamic> json) {
    return PaymentTypeResponse(
      id: json['id'].toString(),
      title: (json['title'] ?? json['name'] ?? '') as String,
      icon: (json['icon'] ?? json['logo'] ?? json['image']) as String?,
      url: json['url'] as String?,
    );
  }

  PaymentTypeEntity toEntity() => PaymentTypeEntity(
    id: id,
    title: title,
    iconUrl: resolveMediaUrl(icon),
    checkoutUrl: url,
  );
}
