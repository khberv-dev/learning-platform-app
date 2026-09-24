/// A unit inside a course, as listed by `GET courses/:courseId/units`. Its
/// lessons live behind a separate call — see [LessonEntity].
class UnitEntity {
  final String id;
  final String title;
  final int lessonsCount;

  const UnitEntity({
    required this.id,
    required this.title,
    required this.lessonsCount,
  });
}
