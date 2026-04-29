import 'package:student/core/courses/data/model/lesson_response.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';

class UnitResponse {
  final String id;
  final int number;
  final String title;
  final int lessonsCount;
  final List<LessonResponse> lessons;

  const UnitResponse({
    required this.id,
    required this.number,
    required this.title,
    required this.lessonsCount,
    required this.lessons,
  });

  factory UnitResponse.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'] as List<dynamic>? ?? [];
    final lessons = rawLessons
        .map((e) => LessonResponse.fromJson(e as Map<String, dynamic>))
        .toList();
    return UnitResponse(
      id: json['id'].toString(),
      number: (json['number'] ?? json['order'] ?? 0) as int,
      title: json['title'] as String,
      lessonsCount:
          (json['lessonsCount'] ?? json['lessons_count'] ?? lessons.length)
              as int,
      lessons: lessons,
    );
  }

  UnitEntity toEntity() => UnitEntity(
    id: id,
    number: number,
    title: title,
    lessonsCount: lessonsCount,
    lessons: lessons.map((l) => l.toEntity()).toList(),
  );
}
