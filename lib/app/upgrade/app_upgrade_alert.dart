import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/ui/startup/splash_screen.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version/version.dart';

/// Oldest build the API still works with. While it is null the prompt is
/// always skippable — the student can take Later or Ignore and carry on.
///
/// Set it to a released version to make the prompt unskippable for anything
/// older: `upgrader` drops both Later and Ignore once the installed version
/// falls below this, and [AppUpgradeAlert] blocks the back button to match.
/// That is the lever to pull when an API change breaks older clients.
const String? minSupportedAppVersion = null;

/// Wraps the app in `upgrader`'s update prompt.
///
/// Mount it from `MaterialApp.router`'s builder rather than above it — the
/// dialog needs a Navigator and the app's localisations to exist first.
class AppUpgradeAlert extends StatefulWidget {
  /// The app's router. Its navigator is what the dialog is pushed onto —
  /// without it `upgrader` uses the builder's context and the dialog never
  /// appears under GoRouter — and its current location is what tells us the
  /// splash screen is out of the way.
  final GoRouter router;

  final Widget child;

  const AppUpgradeAlert({super.key, required this.router, required this.child});

  @override
  State<AppUpgradeAlert> createState() => _AppUpgradeAlertState();
}

class _AppUpgradeAlertState extends State<AppUpgradeAlert> {
  late final Upgrader _upgrader = Upgrader(
    minAppVersion: minSupportedAppVersion,
    debugLogging: kDebugMode,
    // Bypasses the "have we asked recently" and "did they ignore this version"
    // checks, so every debug launch shows the prompt.
    debugDisplayAlways: kDebugMode,
    // In debug the store lookup is replaced wholesale: a real one would 404
    // for an unpublished build, leaving versionInfo null and the prompt
    // silently never showing, however hard debugDisplayAlways tried.
    //
    // Every platform is covered, not just the two we ship: `upgrader` shows
    // nothing at all on a platform with no store, and `flutter test` runs as
    // macOS, which by default has none.
    storeController: kDebugMode
        ? UpgraderStoreController(
            onAndroid: _DebugStore.new,
            oniOS: _DebugStore.new,
            onFuchsia: _DebugStore.new,
            onLinux: _DebugStore.new,
            onMacOS: _DebugStore.new,
            onWeb: _DebugStore.new,
            onWindows: _DebugStore.new,
          )
        : UpgraderStoreController(),
  );

  /// Has the splash screen handed over to a real screen yet?
  ///
  /// The dialog is a pageless route sitting on top of whatever page is
  /// showing, so the `go` that ends the splash animation replaces the stack
  /// and takes the dialog down with it. `upgrader` offers the prompt only
  /// once per launch, so a prompt shown over the splash is a prompt lost.
  bool _pastSplash = false;

  @override
  void initState() {
    super.initState();

    _pastSplash = _hasLeftSplash;
    if (!_pastSplash) {
      widget.router.routerDelegate.addListener(_onRouteChanged);
    }
  }

  bool get _hasLeftSplash {
    final path = widget.router.routerDelegate.currentConfiguration.uri.path;
    // Empty while the router is still working out its first location.
    return path.isNotEmpty && path != SplashScreen.path;
  }

  void _onRouteChanged() {
    if (!_hasLeftSplash) return;
    // Only the first hand-over matters; later navigation is none of our
    // business.
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    setState(() => _pastSplash = true);
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Held in a slot of its own, so that the prompt appearing later leaves
        // the app's element tree — and with it every screen's state — alone.
        widget.child,
        if (_pastSplash)
          UpgradeAlert(
            upgrader: _upgrader,
            navigatorKey: widget.router.routerDelegate.navigatorKey,
            // Skippable: both routes out stay on the dialog. `upgrader` hides
            // them by itself once the build is below [minSupportedAppVersion].
            showIgnore: true,
            showLater: true,
            // The store's "what's new" text, which is marketing copy of
            // unpredictable length. The prompt reads better without it.
            showReleaseNotes: false,
            // Skipping should be a deliberate button press, not a stray tap on
            // the scrim — and once blocked, tapping out must not be an escape
            // at all.
            barrierDismissible: false,
            shouldPopScope: () => !_upgrader.blocked(),
          ),
      ],
    );
  }
}

/// Stands in for the real stores while debugging, reporting a version above
/// whatever is installed so the prompt always has something to offer.
class _DebugStore extends UpgraderStore {
  @override
  Future<UpgraderVersionInfo> getVersionInfo({
    required UpgraderState state,
    required Version installedVersion,
    required String? country,
    required String? language,
  }) async {
    return UpgraderVersionInfo(
      installedVersion: installedVersion,
      appStoreVersion: Version(
        installedVersion.major,
        installedVersion.minor,
        installedVersion.patch + 1,
      ),
      appStoreListingURL: 'https://i-teach.uz',
    );
  }
}
