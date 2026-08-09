/// File kind of a lesson material. The API accepts PDF and Word uploads only.
///
/// Named with the `Lesson` prefix because Flutter's `material.dart` already
/// exports a `MaterialType`, and every screen showing these imports it.
enum LessonMaterialType {
  pdf,
  doc,
  image;

  static LessonMaterialType? fromJson(String? raw) => switch (raw) {
    'pdf' => LessonMaterialType.pdf,
    'doc' => LessonMaterialType.doc,
    'image' => LessonMaterialType.image,
    _ => null,
  };

  String get label => switch (this) {
    LessonMaterialType.pdf => 'PDF',
    LessonMaterialType.doc => 'DOC',
    LessonMaterialType.image => 'IMAGE',
  };
}

/// A downloadable handout attached to a lesson.
class LessonMaterialEntity {
  final String id;
  final String name;

  /// CDN path as stored by the API, e.g. `/material/<uuid>.pdf`.
  final String url;

  /// Null when the API sends a kind this build doesn't know yet — the file is
  /// still openable, it just gets a neutral icon.
  final LessonMaterialType? type;

  const LessonMaterialEntity({
    required this.id,
    required this.name,
    required this.url,
    this.type,
  });
}
