/// Device operating system, as the API's `SessionOs` enum spells it.
enum SessionOs {
  android,
  ios;

  String get value => name;
}

/// A registered device: the FCM token the API pushes to, plus which OS it is.
class SessionEntity {
  final String id;
  final SessionOs? os;
  final String fcmToken;

  const SessionEntity({required this.id, required this.fcmToken, this.os});
}
