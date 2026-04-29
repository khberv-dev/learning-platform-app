import 'package:student/core/courses/domain/entity/unit_entity.dart';

class CourseDetailEntity {
  final String id;
  final String title;
  final int lessonsCount;
  final String? image;
  final int price;
  final List<UnitEntity> units;

  const CourseDetailEntity({
    required this.id,
    required this.title,
    required this.lessonsCount,
    required this.price,
    required this.units,
    this.image,
  });
}
