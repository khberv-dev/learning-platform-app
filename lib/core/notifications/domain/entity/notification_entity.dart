class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final Map<String, String>? data;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.data,
  });
}
