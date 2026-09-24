/// A lesson inside a unit, as listed by
/// `GET courses/:courseId/units/:unitId/lessons`. Its media, materials and
/// task progress live behind a separate call — see [LessonDetailEntity].
class LessonEntity {
  final String id;
  final String title;
  final String? description;
  final bool isLocked;

  const LessonEntity({
    required this.id,
    required this.title,
    this.description,
    this.isLocked = false,
  });
}
