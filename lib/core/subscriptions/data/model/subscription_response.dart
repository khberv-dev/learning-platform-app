import 'package:student/core/subscriptions/domain/entity/subscription_entity.dart';

class SubscriptionResponse {
  final String id;
  final String courseId;
  final String courseTitle;
  final String? courseImage;
  final DateTime start;
  final DateTime end;
  final bool isActive;

  const SubscriptionResponse({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.start,
    required this.end,
    required this.isActive,
    this.courseImage,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>? ?? const {};
    return SubscriptionResponse(
      id: json['id'].toString(),
      courseId: course['id']?.toString() ?? '',
      courseTitle: course['title'] as String? ?? '',
      courseImage: course['image'] as String?,
      start: DateTime.parse(json['start'] as String).toLocal(),
      end: DateTime.parse(json['end'] as String).toLocal(),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  SubscriptionEntity toEntity() => SubscriptionEntity(
    id: id,
    course: SubscriptionCourseEntity(
      id: courseId,
      title: courseTitle,
      image: courseImage,
    ),
    start: start,
    end: end,
    isActive: isActive,
  );
}
