import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_floating_message.dart';

/// The message to show for a failed request: the API's own wording when it
/// sent one, and a translated fallback when it did not.
///
/// Takes a context for the fallback — server-sent messages come through in
/// whatever language the API wrote them in, which is not ours to fix here.
String apiErrorMessage(BuildContext context, Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.first.toString();
    }
  }
  return AppLocalizations.of(context).commonSomethingWentWrong;
}

/// A red message sliding down from the top: [message] as the title, [detail]
/// as an optional grey line under it.
void showErrorMessage(BuildContext context, String message, {String? detail}) {
  showErrorOn(_overlayOf(context), message, detail: detail);
}

/// The green counterpart of [showErrorMessage], for a confirmed outcome.
void showSuccessMessage(
  BuildContext context,
  String message, {
  String? detail,
}) {
  showSuccessOn(_overlayOf(context), message, detail: detail);
}

/// The overlay to show messages on, for [showErrorOn]/[showSuccessOn].
///
/// The root one, so a message outlives the route that raised it (a dialog
/// popping, a screen being replaced) and sits above everything.
OverlayState messageOverlayOf(BuildContext context) => _overlayOf(context);

OverlayState _overlayOf(BuildContext context) =>
    Overlay.of(context, rootOverlay: true);

/// For when the screen that started the work may be gone by the time the
/// outcome is known — capture [messageOverlayOf] before navigating away.
void showErrorOn(OverlayState overlay, String message, {String? detail}) {
  _show(overlay, AppMessageType.error, message, detail);
}

/// [showErrorOn] for a success message.
void showSuccessOn(OverlayState overlay, String message, {String? detail}) {
  _show(overlay, AppMessageType.success, message, detail);
}

/// The one message on screen; a new one replaces it outright.
OverlayEntry? _current;

void _show(
  OverlayState overlay,
  AppMessageType type,
  String message,
  String? detail,
) {
  if (!overlay.mounted) return;
  _removeCurrent();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _TopMessage(
      onDismissed: () {
        if (identical(_current, entry)) _removeCurrent();
      },
      child: AppFloatingMessage(type: type, title: message, detail: detail),
    ),
  );
  _current = entry;
  overlay.insert(entry);
}

void _removeCurrent() {
  final entry = _current;
  _current = null;
  if (entry != null && entry.mounted) entry.remove();
}

/// Slides [child] down from above the top edge, holds it for
/// [_visibleFor], then slides it back up. Tap or swipe up to dismiss early.
class _TopMessage extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismissed;

  const _TopMessage({required this.child, required this.onDismissed});

  @override
  State<_TopMessage> createState() => _TopMessageState();
}

const _visibleFor = Duration(seconds: 4);

class _TopMessageState extends State<_TopMessage>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    reverseDuration: const Duration(milliseconds: 250),
  );
  late final _offset = Tween(begin: const Offset(0, -1), end: Offset.zero)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _hideTimer = Timer(_visibleFor, _dismiss);
  }

  Future<void> _dismiss() async {
    _hideTimer?.cancel();
    if (!mounted || _controller.status == AnimationStatus.reverse) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offset,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) < 0) _dismiss();
              },
              child: Semantics(
                liveRegion: true,
                // The overlay sits above the app's Material, so give the
                // text one to inherit its style from.
                child: Material(
                  type: MaterialType.transparency,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
