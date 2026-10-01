/// A lesson inside a unit, as listed by
/// `GET courses/:courseId/units/:unitId/lessons`. Its media, materials and
/// task progress live behind a separate call — see [LessonDetailEntity].
class LessonEntity {
  final String id;
  final String title;
  final String? description;
  final bool isLocked;

  /// How long the lesson's video runs. Null when the API doesn't say.
  final Duration? duration;

  /// 0–100 on the lesson's tasks, or null when the list doesn't say.
  final int? progressPercent;

  /// The score that counts as having passed a lesson.
  static const passPercent = 80;

  bool get isPassed => (progressPercent ?? 0) >= passPercent;

  const LessonEntity({
    required this.id,
    required this.title,
    this.description,
    this.isLocked = false,
    this.duration,
    this.progressPercent,
  });
}
