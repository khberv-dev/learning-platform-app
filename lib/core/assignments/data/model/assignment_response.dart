import 'package:student/core/assignments/domain/entity/assignment_entity.dart';
import 'package:student/core/mentors/data/model/mentor_response.dart';

class AssignmentResponse {
  final String id;
  final String subscriptionId;
  final String? status;
  final List<ScheduleSlot> schedule;
  final String courseId;
  final String courseTitle;
  final MentorResponse? mentor;

  const AssignmentResponse({
    required this.id,
    required this.subscriptionId,
    this.status,
    this.schedule = const [],
    this.courseId = '',
    this.courseTitle = '',
    this.mentor,
  });

  /// `schedule` is a list of single-entry maps — `[{ "mon": "09:00" }, …]`.
  factory AssignmentResponse.fromJson(Map<String, dynamic> json) {
    final subscription = json['subscription'] as Map<String, dynamic>?;
    final course = subscription?['course'] as Map<String, dynamic>?;
    final mentor = json['mentor'];
    return AssignmentResponse(
      id: json['id'].toString(),
      subscriptionId: subscription?['id']?.toString() ?? '',
      courseId: course?['id']?.toString() ?? '',
      courseTitle: course?['title'] as String? ?? '',
      mentor: mentor is Map<String, dynamic>
          ? MentorResponse.fromJson(mentor)
          : null,
      status: json['status'] as String?,
      schedule: [
        for (final slot in json['schedule'] as List<dynamic>? ?? const [])
          if (slot is Map<String, dynamic>)
            for (final entry in slot.entries)
              if (Weekday.parse(entry.key) case final day?)
                if (entry.value is String)
                  ScheduleSlot(day: day, time: entry.value as String),
      ],
    );
  }

  AssignmentEntity toEntity() => AssignmentEntity(
    id: id,
    subscriptionId: subscriptionId,
    status: AssignmentStatus.parse(status),
    schedule: schedule,
    courseId: courseId,
    courseTitle: courseTitle,
    mentor: mentor?.toEntity(),
  );
}
