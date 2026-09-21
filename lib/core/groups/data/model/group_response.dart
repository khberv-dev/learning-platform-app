import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/mentors/data/model/mentor_response.dart';

class GroupMentorResponse {
  final String id;
  final String role;
  final MentorResponse mentor;

  const GroupMentorResponse({
    required this.id,
    required this.role,
    required this.mentor,
  });

  factory GroupMentorResponse.fromJson(Map<String, dynamic> json) {
    return GroupMentorResponse(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? 'support',
      mentor: MentorResponse.fromJson(
        json['mentor'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  GroupMentorEntity toEntity() => GroupMentorEntity(
    id: id,
    role: GroupMentorRole.parse(role),
    mentor: mentor.toEntity(),
  );
}

class GroupStudentResponse {
  final String id;
  final String firstName;
  final String? lastName;
  final String? avatar;
  final String? level;

  const GroupStudentResponse({
    required this.id,
    required this.firstName,
    this.lastName,
    this.avatar,
    this.level,
  });

  factory GroupStudentResponse.fromJson(Map<String, dynamic> json) =>
      GroupStudentResponse(
        id: json['id'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String?,
        avatar: json['avatar'] as String?,
        level: json['level'] as String?,
      );

  GroupStudentEntity toEntity() => GroupStudentEntity(
    id: id,
    firstName: firstName,
    lastName: lastName,
    avatar: avatar,
    level: level,
  );
}

class GroupResponse {
  final String id;
  final String title;
  final Map<String, List<String>> schedule;
  final bool isActive;
  final List<GroupMentorResponse> mentors;
  final List<GroupStudentResponse> students;

  const GroupResponse({
    required this.id,
    required this.title,
    required this.isActive,
    this.schedule = const {},
    this.mentors = const [],
    this.students = const [],
  });

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    final rawSchedule = json['schedule'] as Map<String, dynamic>? ?? {};
    final rawMentors = json['mentors'] as List<dynamic>? ?? [];
    final rawStudents = json['students'] as List<dynamic>? ?? [];

    return GroupResponse(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      schedule: rawSchedule.map(
        (day, slots) => MapEntry(day, List<String>.from(slots as List)),
      ),
      mentors: rawMentors
          .map((e) => GroupMentorResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      students: rawStudents
          .map((e) => GroupStudentResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  GroupEntity toEntity() => GroupEntity(
    id: id,
    title: title,
    isActive: isActive,
    schedule: schedule,
    mentors: mentors.map((m) => m.toEntity()).toList(),
    students: students.map((s) => s.toEntity()).toList(),
  );
}
