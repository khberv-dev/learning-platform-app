import 'package:student/core/courses/data/model/unit_response.dart';
import 'package:student/core/courses/domain/entity/course_detail_entity.dart';

class CourseDetailResponse {
  final String id;
  final String title;
  final int lessonsCount;
  final String? image;
  final int price;
  final List<UnitResponse> units;

  const CourseDetailResponse({
    required this.id,
    required this.title,
    required this.lessonsCount,
    required this.price,
    required this.units,
    this.image,
  });

  factory CourseDetailResponse.fromJson(Map<String, dynamic> json) {
    final rawUnits = json['units'] as List<dynamic>? ?? [];
    final lessons = json['lessons'] as List<dynamic>?;
    return CourseDetailResponse(
      id: json['id'].toString(),
      title: json['title'] as String,
      lessonsCount:
          (json['lessonsCount'] ??
                  json['lessons_count'] ??
                  lessons?.length ??
                  0)
              as int,
      image: json['image'] as String?,
      price: (json['price'] ?? 0) as int,
      units: rawUnits
          .map((e) => UnitResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  CourseDetailEntity toEntity() => CourseDetailEntity(
    id: id,
    title: title,
    lessonsCount: lessonsCount,
    image: image,
    price: price,
    units: units.map((u) => u.toEntity()).toList(),
  );
}
