/// Someone credited with making a course — one of `authors` on
/// `GET student/courses/:id`.
class CourseAuthorEntity {
  final String id;
  final String firstName;
  final String? lastName;
  final String? avatar;
  final String? description;

  const CourseAuthorEntity({
    required this.id,
    required this.firstName,
    this.lastName,
    this.avatar,
    this.description,
  });

  String get fullName {
    final last = lastName;
    return last == null || last.isEmpty ? firstName : '$firstName $last';
  }
}
