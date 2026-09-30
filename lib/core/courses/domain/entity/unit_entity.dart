/// A unit inside a course, as listed by `GET courses/:courseId/units`. Its
/// lessons live behind a separate call — see [LessonEntity].
class UnitEntity {
  final String id;
  final String title;
  final int lessonsCount;

  /// Not yet open to the student, even in a course they own — e.g. until the
  /// previous unit is finished. False when the API doesn't say.
  final bool isLocked;

  const UnitEntity({
    required this.id,
    required this.title,
    required this.lessonsCount,
    this.isLocked = false,
  });
}
