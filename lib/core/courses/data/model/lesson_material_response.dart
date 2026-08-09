import 'package:student/core/courses/domain/entity/lesson_material_entity.dart';

class LessonMaterialResponse {
  final String id;
  final String name;
  final String url;
  final LessonMaterialType? type;

  const LessonMaterialResponse({
    required this.id,
    required this.name,
    required this.url,
    this.type,
  });

  factory LessonMaterialResponse.fromJson(Map<String, dynamic> json) =>
      LessonMaterialResponse(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        url: json['url'] as String? ?? '',
        type: LessonMaterialType.fromJson(json['type'] as String?),
      );

  LessonMaterialEntity toEntity() =>
      LessonMaterialEntity(id: id, name: name, url: url, type: type);
}
