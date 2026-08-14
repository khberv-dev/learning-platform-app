import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student/app/router/app_router.dart';
import 'package:student/core/notifications/domain/entity/session_entity.dart';
import 'package:student/core/notifications/presentation/local_notifications.dart';
import 'package:student/core/notifications/domain/usecase/use_delete_session.dart';
import 'package:student/core/notifications/domain/usecase/use_register_session.dart';

/// Handles a push that arrives while the app is backgrounded or killed.
///
/// Must stay top-level and keep the entry-point pragma — the OS spins up a
/// fresh isolate to run it, so nothing from the running app is in scope and
/// Firebase has to be initialised again.
@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[push] background message ${message.messageId}');
}

final pushMessagingProvider = Provider<PushMessagingService>((ref) {
  final service = PushMessagingService(ref);
  ref.onDispose(service.dispose);
  return service;
});

/// Owns the device's relationship with FCM: permission, the token, and what
/// happens when a notification arrives or is tapped.
///
/// [start] is called once the student is authenticated, because registering the
/// device hits an endpoint behind the bearer token. [signOut] tears the
/// registration down again, and must run *before* the tokens are cleared.
class PushMessagingService {
  /// Id of the session row this device currently owns on the API — the handle
  /// `DELETE sessions/:id` needs at logout. The FCM token itself isn't kept:
  /// registering upserts on it server-side, so it is never the thing looked up.
  static const _sessionIdKey = 'fcm_session_id';

  /// A push may carry `data.route` naming a screen to open on tap. Anything
  /// else is delivered but leads nowhere.
  static const _routeKey = 'route';

  final Ref _ref;

  bool _hasStarted = false;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  late final LocalNotifications _local = LocalNotifications(onTap: _openRoute);

  PushMessagingService(this._ref);

  Future<void> start() async {
    if (_hasStarted) return;
    _hasStarted = true;

    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[push] permission denied');
        return;
      }

      // iOS shows nothing in the foreground unless asked to; Android ignores
      // this and needs a local-notification plugin for the same effect.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      await _local.init();
      _listen();
      await _syncToken();
      await _handleLaunchMessage();
    } catch (e) {
      // Push is an extra, never a gate on using the app.
      debugPrint('[push] setup failed: $e');
    }
  }

  /// Unregisters the device so the API stops pushing to it, and resets far
  /// enough that the next student to log in on this device registers afresh.
  ///
  /// Call this while the access token is still valid — the endpoint is
  /// authenticated, so clearing storage first would strand the session row.
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString(_sessionIdKey);

    if (sessionId != null) {
      try {
        await _ref.read(useDeleteSessionProvider).call(sessionId);
      } catch (e) {
        // Nothing to retry against once the token goes, so drop it either way
        // and let the row age out server-side.
        debugPrint('[push] deleting the session failed: $e');
      }
      await prefs.remove(_sessionIdKey);
    }

    dispose();
    _hasStarted = false;
  }

  void _listen() {
    _subscriptions.addAll([
      FirebaseMessaging.instance.onTokenRefresh.listen(_replaceRegistration),
      // Android draws nothing for a foreground push, so it is posted by hand.
      FirebaseMessaging.onMessage.listen(_local.show),
      FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage),
    ]);
  }

  /// A tap that launched the app from cold arrives here rather than through
  /// [FirebaseMessaging.onMessageOpenedApp].
  Future<void> _handleLaunchMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) _openFromMessage(message);
  }

  void _openFromMessage(RemoteMessage message) => _openRoute(message.data);

  void _openRoute(Map<String, dynamic> data) {
    final route = data[_routeKey];
    if (route is! String || route.isEmpty) return;
    _ref.read(appRouterProvider).push(route);
  }

  Future<void> _syncToken() async {
    final token = await _fetchToken();
    if (token != null) await _register(token);
  }

  /// On iOS the FCM token is only minted once APNs has handed over its own, so
  /// a cold start can ask too early. Give it a few seconds before giving up.
  Future<String?> _fetchToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      for (var attempt = 0; attempt < 6; attempt++) {
        if (await FirebaseMessaging.instance.getAPNSToken() != null) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return FirebaseMessaging.instance.getToken();
  }

  /// FCM rotated the token, so the row keyed on the old one is dead — drop it
  /// before claiming a new one.
  Future<void> _replaceRegistration(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final previous = prefs.getString(_sessionIdKey);

    if (previous != null) {
      try {
        await _ref.read(useDeleteSessionProvider).call(previous);
      } catch (e) {
        debugPrint('[push] dropping the stale session failed: $e');
      }
    }

    await _register(token);
  }

  /// Registered unconditionally rather than skipped when the token looks
  /// unchanged: the API upserts on the token, so this is what re-points a
  /// shared device at whoever logged in last.
  Future<void> _register(String token) async {
    if (token.isEmpty) return;

    try {
      final session = await _ref
          .read(useRegisterSessionProvider)
          .call(
            os: defaultTargetPlatform == TargetPlatform.iOS
                ? SessionOs.ios
                : SessionOs.android,
            fcmToken: token,
          );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionIdKey, session.id);
    } catch (e) {
      debugPrint('[push] registering the session failed: $e');
    }
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
