import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/app.dart';
import 'package:student/core/notifications/presentation/push_messaging_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Options come from GoogleService-Info.plist and google-services.json, so
  // there is no generated firebase_options.dart to pass here.
  //
  // A device with no Play Services, or a build whose native config is missing,
  // must still reach the app — push is the only thing lost.
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  } catch (e) {
    debugPrint('[push] Firebase unavailable: $e');
  }

  runApp(ProviderScope(child: App()));
}
