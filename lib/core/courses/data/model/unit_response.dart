import 'package:student/core/courses/domain/entity/unit_entity.dart';

class UnitResponse {
  final String id;
  final String title;
  final int lessonsCount;

  const UnitResponse({
    required this.id,
    required this.title,
    required this.lessonsCount,
  });

  factory UnitResponse.fromJson(Map<String, dynamic> json) => UnitResponse(
    id: json['id'].toString(),
    title: json['title'] as String,
    lessonsCount: (json['lessonsCount'] ?? json['lessons_count'] ?? 0) as int,
  );

  UnitEntity toEntity() =>
      UnitEntity(id: id, title: title, lessonsCount: lessonsCount);
}
