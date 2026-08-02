import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] outside the app. Returns false when the device can't.
typedef UrlLauncher = Future<bool> Function(Uri url);

/// Indirection so screens can be driven in tests, where url_launcher's
/// platform channel isn't available.
final urlLauncherProvider = Provider<UrlLauncher>((ref) => launchExternal);

Future<bool> launchExternal(Uri url) async {
  if (!await canLaunchUrl(url)) return false;
  return launchUrl(url, mode: LaunchMode.externalApplication);
}
