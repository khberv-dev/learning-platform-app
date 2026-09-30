import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/mentors/data/model/mentor_response.dart';

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
  final GroupCourseEntity? course;
  final MentorResponse? primaryMentor;
  final List<GroupStudentResponse> students;

  const GroupResponse({
    required this.id,
    required this.title,
    required this.isActive,
    this.schedule = const {},
    this.course,
    this.primaryMentor,
    this.students = const [],
  });

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    final rawSchedule = json['schedule'] as Map<String, dynamic>? ?? {};
    final rawStudents = json['students'] as List<dynamic>? ?? [];
    final rawCourse = json['course'] as Map<String, dynamic>?;

    return GroupResponse(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      schedule: rawSchedule.map(
        (day, slots) => MapEntry(day, List<String>.from(slots as List)),
      ),
      course: rawCourse == null
          ? null
          : GroupCourseEntity(
              id: rawCourse['id'].toString(),
              title: rawCourse['title'] as String? ?? '',
            ),
      primaryMentor: _primaryMentor(json),
      students: rawStudents
          .map((e) => GroupStudentResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// A flat `primaryMentor` object. Falls back to the older `mentors` team
  /// list — `{role, mentor}` pairs — picking the one whose role is primary.
  static MentorResponse? _primaryMentor(Map<String, dynamic> json) {
    final direct = json['primaryMentor'];
    if (direct is Map<String, dynamic>) return MentorResponse.fromJson(direct);

    for (final m in json['mentors'] as List<dynamic>? ?? const []) {
      if (m is Map<String, dynamic> &&
          m['role'] == 'primary' &&
          m['mentor'] is Map<String, dynamic>) {
        return MentorResponse.fromJson(m['mentor'] as Map<String, dynamic>);
      }
    }
    return null;
  }

  GroupEntity toEntity() => GroupEntity(
    id: id,
    title: title,
    isActive: isActive,
    schedule: schedule,
    course: course,
    primaryMentor: primaryMentor?.toEntity(),
    students: students.map((s) => s.toEntity()).toList(),
  );
}
