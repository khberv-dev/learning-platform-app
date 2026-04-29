import 'package:student/core/courses/domain/entity/unit_entity.dart';

class UnitResponse {
  final String id;
  final int number;
  final String title;
  final int lessonsCount;

  const UnitResponse({
    required this.id,
    required this.number,
    required this.title,
    required this.lessonsCount,
  });

  factory UnitResponse.fromJson(Map<String, dynamic> json) {
    final lessons = json['lessons'] as List<dynamic>?;
    return UnitResponse(
      id: json['id'].toString(),
      number: (json['number'] ?? json['order'] ?? 0) as int,
      title: json['title'] as String,
      lessonsCount:
          (json['lessonsCount'] ??
                  json['lessons_count'] ??
                  lessons?.length ??
                  0)
              as int,
    );
  }

  UnitEntity toEntity() => UnitEntity(
    id: id,
    number: number,
    title: title,
    lessonsCount: lessonsCount,
  );
}
