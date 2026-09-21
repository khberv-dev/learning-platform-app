import 'package:student/core/mentors/domain/entity/mentor_entity.dart';

enum GroupMentorRole {
  primary,
  support;

  static GroupMentorRole parse(String? raw) => switch (raw) {
    'primary' => GroupMentorRole.primary,
    _ => GroupMentorRole.support,
  };
}

class GroupMentorEntity {
  final String id;
  final GroupMentorRole role;
  final MentorEntity mentor;

  const GroupMentorEntity({
    required this.id,
    required this.role,
    required this.mentor,
  });
}

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

/// A named cohort with a mentor team and a student roster — the only way a
/// student is paired with a mentor. Membership is fully admin-managed.
class GroupEntity {
  final String id;
  final String title;
  final Map<String, List<String>> schedule;
  final bool isActive;
  final List<GroupMentorEntity> mentors;
  final List<GroupStudentEntity> students;

  const GroupEntity({
    required this.id,
    required this.title,
    required this.isActive,
    this.schedule = const {},
    this.mentors = const [],
    this.students = const [],
  });

  GroupMentorEntity? get primaryMentor {
    for (final m in mentors) {
      if (m.role == GroupMentorRole.primary) return m;
    }
    return null;
  }

  List<GroupMentorEntity> get supportMentors =>
      mentors.where((m) => m.role == GroupMentorRole.support).toList();
}
