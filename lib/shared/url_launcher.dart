import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] outside the app. Returns false when the device can't.
typedef UrlLauncher = Future<bool> Function(Uri url);

/// Indirection so screens can be driven in tests, where url_launcher's
/// platform channel isn't available.
final urlLauncherProvider = Provider<UrlLauncher>((ref) => launchExternal);

/// Like [urlLauncherProvider], but for pages the student reads and comes back
/// from — legal documents — which open over the app instead of leaving it.
final inAppBrowserLauncherProvider = Provider<UrlLauncher>(
  (ref) => launchInAppBrowser,
);

Future<bool> launchExternal(Uri url) async {
  if (!await canLaunchUrl(url)) return false;
  return launchUrl(url, mode: LaunchMode.externalApplication);
}

/// Opens [url] in SFSafariViewController on iOS and a Custom Tab on Android.
///
/// Skips [canLaunchUrl]: on Android 11+ it reports false for https unless the
/// manifest declares a matching `<queries>` entry, while launching itself
/// works without one.
Future<bool> launchInAppBrowser(Uri url) async {
  try {
    return await launchUrl(url, mode: LaunchMode.inAppBrowserView);
  } catch (_) {
    return false;
  }
}
