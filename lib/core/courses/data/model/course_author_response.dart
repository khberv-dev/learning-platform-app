import 'package:student/core/courses/domain/entity/course_author_entity.dart';

class CourseAuthorResponse {
  final String id;
  final String firstName;
  final String? lastName;
  final String? avatar;
  final String? description;

  const CourseAuthorResponse({
    required this.id,
    required this.firstName,
    this.lastName,
    this.avatar,
    this.description,
  });

  factory CourseAuthorResponse.fromJson(Map<String, dynamic> json) =>
      CourseAuthorResponse(
        id: json['id'].toString(),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String?,
        avatar: json['avatar'] as String?,
        description: json['description'] as String?,
      );

  CourseAuthorEntity toEntity() => CourseAuthorEntity(
    id: id,
    firstName: firstName,
    lastName: lastName,
    avatar: avatar,
    description: description,
  );
}
