import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/startup/splash_screen.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

const appStoreUrl = 'https://apps.apple.com/ru/app/iteach/id6797769925';
const playStoreUrl =
    'https://play.google.com/store/apps/details?id=uz.iteach.student';

/// The store listing for the platform the app is running on.
Uri storeListingUrl() => Uri.parse(
  defaultTargetPlatform == TargetPlatform.iOS ? appStoreUrl : playStoreUrl,
);

/// Opens [url] in the store app (or the browser when it isn't installed).
///
/// Skips `canLaunchUrl`: on Android 11+ it reports false for https unless the
/// manifest declares a matching `<queries>` entry, while launching itself
/// works without one.
Future<bool> _openStore(Uri url) async {
  try {
    return await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Wraps the app in the store-update prompt: `upgrader` does the version
/// check, and [_UpdateSheet] replaces its stock dialog with a bottom sheet.
///
/// In release builds the sheet is **unmissable** — no close button, no drag
/// or scrim dismissal, no back — and returns on every launch until the app is
/// updated. In debug it can be dismissed, so development isn't blocked.
///
/// Mount it from `MaterialApp.router`'s builder rather than above it — the
/// sheet needs a Navigator and the app's localisations to exist first.
class AppUpgradeAlert extends StatefulWidget {
  /// The app's router. Its navigator is what the sheet is pushed onto —
  /// without it `upgrader` uses the builder's context and the sheet never
  /// appears under GoRouter — and its current location is what tells us the
  /// splash screen is out of the way.
  final GoRouter router;

  /// Whether the student can close the sheet without updating. Defaults to
  /// debug builds only; exposed so tests can check the release behaviour.
  final bool dismissible;

  /// Opens the store listing from the Update button. Swappable for tests,
  /// where url_launcher's platform channel doesn't exist.
  final Future<bool> Function(Uri url) openStore;

  final Widget child;

  const AppUpgradeAlert({
    super.key,
    required this.router,
    required this.child,
    this.dismissible = kDebugMode,
    this.openStore = _openStore,
  });

  @override
  State<AppUpgradeAlert> createState() => _AppUpgradeAlertState();
}

class _AppUpgradeAlertState extends State<AppUpgradeAlert> {
  late final Upgrader _upgrader = Upgrader(
    debugLogging: kDebugMode,
    // Unmissable means asking again on every launch, not waiting out
    // upgrader's default 3-day "asked recently" window.
    durationUntilAlertAgain: widget.dismissible
        ? const Duration(days: 3)
        : Duration.zero,
    // Bypasses the "have we asked recently" and "did they ignore this version"
    // checks, so every debug launch shows the prompt — but only the first
    // time `shouldDisplayUpgrade` is evaluated per launch (it flips
    // `_hasAlerted` the instant it's shown). `debugDisplayAlways` would
    // re-force it on every later check too — e.g. every app resume, since
    // `checkOnResume` defaults to true — showing it more than once a session.
    debugDisplayOnce: kDebugMode,
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
  /// The sheet is a pageless route sitting on top of whatever page is
  /// showing, so the `go` that ends the splash animation replaces the stack
  /// and takes the sheet down with it. `upgrader` offers the prompt only
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
          _UpdateSheetAlert(
            upgrader: _upgrader,
            navigatorKey: widget.router.routerDelegate.navigatorKey,
            dismissible: widget.dismissible,
            openStore: widget.openStore,
          ),
      ],
    );
  }
}

/// `upgrader`'s alert with the dialog swapped for [_UpdateSheet] — the
/// version check, store lookup and bookkeeping are all still upgrader's.
class _UpdateSheetAlert extends UpgradeAlert {
  final bool dismissible;
  final Future<bool> Function(Uri url) openStore;

  _UpdateSheetAlert({
    required super.upgrader,
    required super.navigatorKey,
    required this.dismissible,
    required this.openStore,
  }) : super(
         // No Later/Ignore: the sheet has one action, and ignoring a version
         // would make an unmissable prompt missable.
         showIgnore: false,
         showLater: false,
         showReleaseNotes: false,
         barrierDismissible: dismissible,
       );

  @override
  UpgradeAlertState createState() => _UpdateSheetAlertState();
}

class _UpdateSheetAlertState extends UpgradeAlertState {
  _UpdateSheetAlert get _alert => widget as _UpdateSheetAlert;
  bool get _dismissible => _alert.dismissible;

  /// Our own listing links rather than upgrader's `sendUserToAppStore`, whose
  /// URL comes from the store lookup (and in debug, from the stand-in store).
  void _onUpdate(BuildContext sheetContext) {
    _alert.openStore(storeListingUrl());
    // Unmissable: the sheet stays up behind the store, so coming back
    // without updating still lands on it.
    if (_dismissible) popNavigator(sheetContext);
  }

  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    if (!context.mounted) return;
    widget.upgrader.saveLastAlerted();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: _dismissible,
      enableDrag: _dismissible,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => PopScope(
        canPop: _dismissible,
        child: _UpdateSheet(key: key, onUpdate: () => _onUpdate(sheetContext)),
      ),
    ).whenComplete(() => displayed = false);
  }
}

/// Icon, title, body and a single Update button, per the redesign mockup.
class _UpdateSheet extends StatelessWidget {
  final VoidCallback onUpdate;

  const _UpdateSheet({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/ic_update.png', width: 60, height: 60),
            const SizedBox(height: 20),
            Text(
              l10n.updateTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF15141A),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                l10n.updateBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF717384),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppFlatPillButton(
              label: l10n.updateAction,
              background: const Color(0xFF78C83C),
              foreground: Colors.white,
              onTap: onUpdate,
            ),
          ],
        ),
      ),
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
