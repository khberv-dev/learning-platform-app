class LiveLessonScheduledEntity {
  final String id;
  final String name;
  final String meetLink;
  final DateTime startTime;
  final DateTime endTime;
  final String teacherName;

  const LiveLessonScheduledEntity({
    required this.id,
    required this.name,
    required this.meetLink,
    required this.startTime,
    required this.endTime,
    required this.teacherName,
  });

  bool get isUpcoming => startTime.isAfter(DateTime.now());

  bool get isOngoing =>
      startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now());
}
