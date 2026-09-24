import 'package:student/core/courses/domain/entity/unit_entity.dart';

class CourseDetailEntity {
  final String id;
  final String title;
  final int lessonsCount;
  final String? image;
  final List<UnitEntity> units;
  final DateTime? announcedAt;

  const CourseDetailEntity({
    required this.id,
    required this.title,
    required this.lessonsCount,
    required this.units,
    this.image,
    this.announcedAt,
  });
}
