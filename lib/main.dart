import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/app.dart';
import 'package:student/app/locale/locale_controller.dart';
import 'package:student/app/locale/locale_storage.dart';
import 'package:student/core/diagnostics/error_reporting.dart';
import 'package:student/core/notifications/presentation/push_messaging_service.dart';

Future<void> main() async {
  // Both the binding and runApp must live in the same zone, so everything
  // else goes inside it too rather than wrapping just runApp.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Keeps the red debug screen / console dump, and reports on top of it —
      // this only fires for errors thrown during a widget's build/layout/paint.
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        unawaited(reportAppError(details.exceptionAsString(), details.stack));
      };
      // Uncaught errors outside Flutter's own error zone (async gaps,
      // platform channel callbacks, ...).
      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(reportAppError(error, stack));
        return true;
      };

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

      // Read before the first frame: starting in one language and swapping to
      // the stored one a frame later would be visible on the splash screen.
      final language = await LocaleStorage().getLanguage();

      runApp(
        ProviderScope(
          overrides: [startupLanguageProvider.overrideWithValue(language)],
          child: App(),
        ),
      );
    },
    // Anything that still slips past the two handlers above (e.g. before they
    // were installed).
    (error, stack) => unawaited(reportAppError(error, stack)),
  );
}
