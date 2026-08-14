import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Draws notifications Android would otherwise swallow.
///
/// FCM only posts a notification itself while the app is backgrounded. In the
/// foreground it hands the message to `onMessage` and draws nothing, so on
/// Android the student sees nothing at all unless the app posts it. iOS has no
/// such gap — `setForegroundNotificationPresentationOptions` covers it — so
/// this deliberately only runs on Android.
class LocalNotifications {
  /// Must match `default_notification_channel_id` in the manifest, so a
  /// foreground notification and a background one land in the same channel and
  /// share whatever the student has muted or allowed.
  static const channelId = 'iteach_default';
  static const _channelName = 'General';
  static const _channelDescription = 'Lesson reminders, messages and updates';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isReady = false;

  /// Invoked with the message's data payload when a notification this class
  /// posted is tapped.
  final void Function(Map<String, dynamic> data) onTap;

  LocalNotifications({required this.onTap});

  Future<void> init() async {
    if (_isReady || defaultTargetPlatform != TargetPlatform.android) return;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      ),
      onDidReceiveNotificationResponse: _onResponse,
    );

    // Creating it up front means the channel's name and importance are already
    // right the first time a background push arrives — FCM would otherwise
    // create it implicitly with whatever the manifest implies.
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );

    _isReady = true;
  }

  /// Posts [message] as a notification. No-op unless it carries something to
  /// show — a data-only push has no title or body to draw.
  Future<void> show(RemoteMessage message) async {
    if (!_isReady) return;

    final notification = message.notification;
    if (notification == null) return;

    await _plugin.show(
      // Collapses repeats of the same notification rather than stacking them.
      id: message.messageId.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        ),
      ),
      // The tap callback gets a payload string, not the message, so the data
      // has to travel encoded.
      payload: jsonEncode(message.data),
    );
  }

  void _onResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) onTap(data);
    } catch (e) {
      debugPrint('[push] unreadable notification payload: $e');
    }
  }
}
