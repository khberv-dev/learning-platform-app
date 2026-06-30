import 'package:student/core/live_lessons/domain/entity/live_lesson_scheduled_entity.dart';

class LiveLessonScheduledResponse {
  final String id;
  final String name;
  final String meetLink;
  final DateTime startTime;
  final DateTime endTime;
  final String teacherName;

  const LiveLessonScheduledResponse({
    required this.id,
    required this.name,
    required this.meetLink,
    required this.startTime,
    required this.endTime,
    required this.teacherName,
  });

  factory LiveLessonScheduledResponse.fromJson(Map<String, dynamic> json) {
    // Teacher user is at lesson.teacher.user OR lesson.assignment.teacher.user
    final directTeacher = json['teacher'] as Map<String, dynamic>?;
    final assignment = json['assignment'] as Map<String, dynamic>?;
    final assignmentTeacher = assignment?['teacher'] as Map<String, dynamic>?;
    final user = (directTeacher?['user'] ?? assignmentTeacher?['user'])
        as Map<String, dynamic>?;
    final firstName = user?['firstName'] as String? ?? '';
    final lastName = user?['lastName'] as String? ?? '';
    final teacherName =
        [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    return LiveLessonScheduledResponse(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      meetLink: json['meetLink'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      teacherName: teacherName,
    );
  }

  LiveLessonScheduledEntity toEntity() => LiveLessonScheduledEntity(
    id: id,
    name: name,
    meetLink: meetLink,
    startTime: startTime,
    endTime: endTime,
    teacherName: teacherName,
  );
}
