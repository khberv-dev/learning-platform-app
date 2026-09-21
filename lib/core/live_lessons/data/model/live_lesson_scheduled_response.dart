import 'package:student/core/live_lessons/domain/entity/live_lesson_scheduled_entity.dart';

class LiveLessonScheduledResponse {
  final String id;
  final String name;
  final String meetLink;
  final DateTime startTime;
  final DateTime endTime;
  final String mentorName;

  const LiveLessonScheduledResponse({
    required this.id,
    required this.name,
    required this.meetLink,
    required this.startTime,
    required this.endTime,
    required this.mentorName,
  });

  factory LiveLessonScheduledResponse.fromJson(Map<String, dynamic> json) {
    // The mentor who scheduled the lesson — flat, firstName/lastName sit
    // directly on it.
    final mentor = json['mentor'] as Map<String, dynamic>?;
    final firstName = mentor?['firstName'] as String? ?? '';
    final lastName = mentor?['lastName'] as String? ?? '';
    final mentorName = [
      firstName,
      lastName,
    ].where((s) => s.isNotEmpty).join(' ');

    return LiveLessonScheduledResponse(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      meetLink: json['meetLink'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      mentorName: mentorName,
    );
  }

  LiveLessonScheduledEntity toEntity() => LiveLessonScheduledEntity(
    id: id,
    name: name,
    meetLink: meetLink,
    startTime: startTime,
    endTime: endTime,
    mentorName: mentorName,
  );
}
