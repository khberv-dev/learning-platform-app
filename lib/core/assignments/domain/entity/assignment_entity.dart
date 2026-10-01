import 'package:student/core/mentors/domain/entity/mentor_entity.dart';

/// A day of the week, in the API's `mon`…`sun` codes, Monday first.
enum Weekday {
  mon,
  tue,
  wed,
  thu,
  fri,
  sat,
  sun;

  static Weekday? parse(String? code) {
    for (final day in values) {
      if (day.name == code) return day;
    }
    return null;
  }
}

/// One weekly lesson slot: a day and an `HH:mm` time.
class ScheduleSlot {
  final Weekday day;
  final String time;

  const ScheduleSlot({required this.day, required this.time});

  @override
  bool operator ==(Object other) =>
      other is ScheduleSlot && other.day == day && other.time == time;

  @override
  int get hashCode => Object.hash(day, time);
}

enum AssignmentStatus {
  /// Asked for, not yet matched to a group and mentor.
  pending,
  active;

  static AssignmentStatus parse(String? raw) =>
      raw == 'active' ? AssignmentStatus.active : AssignmentStatus.pending;
}

/// A student's request to be placed in a group for one subscription, with
/// the weekly times they asked for. One per subscription.
class AssignmentEntity {
  final String id;
  final String subscriptionId;
  final AssignmentStatus status;
  final List<ScheduleSlot> schedule;

  /// The course of the subscription it's for.
  final String courseId;
  final String courseTitle;

  /// The mentor an admin has matched the student with — null until then.
  final MentorEntity? mentor;

  const AssignmentEntity({
    required this.id,
    required this.subscriptionId,
    required this.status,
    this.schedule = const [],
    this.courseId = '',
    this.courseTitle = '',
    this.mentor,
  });
}
