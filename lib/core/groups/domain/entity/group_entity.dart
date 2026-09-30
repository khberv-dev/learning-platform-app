import 'package:student/core/mentors/domain/entity/mentor_entity.dart';

class GroupStudentEntity {
  final String id;
  final String firstName;
  final String? lastName;
  final String? avatar;
  final String? level;

  const GroupStudentEntity({
    required this.id,
    required this.firstName,
    this.lastName,
    this.avatar,
    this.level,
  });

  String get fullName => (lastName != null && lastName!.isNotEmpty)
      ? '$firstName $lastName'
      : firstName;
}

/// The course a group studies.
class GroupCourseEntity {
  final String id;
  final String title;

  const GroupCourseEntity({required this.id, required this.title});
}

/// A named cohort studying one course, led by a single primary mentor — the
/// only way a student is paired with a mentor. Membership is fully
/// admin-managed, and a student can be in several groups, one per course.
class GroupEntity {
  final String id;
  final String title;
  final Map<String, List<String>> schedule;
  final bool isActive;
  final GroupCourseEntity? course;

  /// Null until an admin assigns one.
  final MentorEntity? primaryMentor;

  final List<GroupStudentEntity> students;

  const GroupEntity({
    required this.id,
    required this.title,
    required this.isActive,
    this.schedule = const {},
    this.course,
    this.primaryMentor,
    this.students = const [],
  });
}
