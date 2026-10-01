/// The course a subscription gives access to.
class SubscriptionCourseEntity {
  final String id;
  final String title;
  final String? image;

  const SubscriptionCourseEntity({
    required this.id,
    required this.title,
    this.image,
  });
}

/// Paid access to one course for a period. A student can hold several, one
/// per course, each running out on its own date.
class SubscriptionEntity {
  final String id;
  final SubscriptionCourseEntity course;
  final DateTime start;
  final DateTime end;

  /// The API's own flag — false once cancelled or lapsed.
  final bool isActive;

  const SubscriptionEntity({
    required this.id,
    required this.course,
    required this.start,
    required this.end,
    required this.isActive,
  });

  /// Still giving access at [now]: flagged active and not yet past its end.
  bool isCurrentAt(DateTime now) => isActive && end.isAfter(now);
}
