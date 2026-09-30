import 'package:student/core/plans/domain/entity/plan_entity.dart';

class PlanResponse {
  final String id;
  final String title;
  final int price;
  final int month;
  final bool isActive;

  const PlanResponse({
    required this.id,
    required this.title,
    required this.price,
    required this.month,
    this.isActive = true,
  });

  factory PlanResponse.fromJson(Map<String, dynamic> json) => PlanResponse(
    id: json['id'].toString(),
    title: (json['title'] ?? '') as String,
    price: (json['price'] as num?)?.toInt() ?? 0,
    month: (json['month'] as num?)?.toInt() ?? 0,
    isActive: json['isActive'] as bool? ?? true,
  );

  PlanEntity toEntity() =>
      PlanEntity(id: id, title: title, price: price, month: month);
}
