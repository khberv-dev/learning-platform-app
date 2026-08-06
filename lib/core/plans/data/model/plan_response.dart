import 'package:student/core/plans/domain/entity/plan_entity.dart';

class PlanResponse {
  final String id;
  final String title;
  final int price;
  final int month;
  final bool hasMentor;

  const PlanResponse({
    required this.id,
    required this.title,
    required this.price,
    required this.month,
    required this.hasMentor,
  });

  factory PlanResponse.fromJson(Map<String, dynamic> json) => PlanResponse(
    id: json['id'].toString(),
    title: (json['title'] ?? '') as String,
    price: (json['price'] as num?)?.toInt() ?? 0,
    month: (json['month'] as num?)?.toInt() ?? 0,
    hasMentor: (json['hasMentor'] ?? false) as bool,
  );

  PlanEntity toEntity() => PlanEntity(
    id: id,
    title: title,
    price: price,
    month: month,
    hasMentor: hasMentor,
  );
}
