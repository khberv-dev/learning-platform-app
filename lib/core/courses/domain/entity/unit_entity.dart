import 'package:student/core/courses/domain/entity/lesson_entity.dart';

class UnitEntity {
  final String id;
  final int number;
  final String title;
  final int lessonsCount;
  final List<LessonEntity> lessons;

  const UnitEntity({
    required this.id,
    required this.number,
    required this.title,
    required this.lessonsCount,
    required this.lessons,
  });
}
