import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';

const _ink = Color(0xFF15141A);
const _muted = Color(0xFF6D737E);
const _danger = Color(0xFFEF5B5B);
const _dangerFill = Color(0xFFFDECEC);

/// Asks the student to confirm a destructive step in a bottom sheet: a red
/// badge with [icon], a [title] question, a [message] explaining what
/// happens, and Cancel / [confirmLabel] side by side.
///
/// Completes with true only when the red button is tapped — Cancel, a swipe
/// down or a tap outside all count as no.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required Widget icon,
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) => AppConfirmSheet(
      icon: icon,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
    ),
  );
  return confirmed ?? false;
}

class AppConfirmSheet extends StatelessWidget {
  final Widget icon;
  final String title;
  final String message;
  final String confirmLabel;

  const AppConfirmSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: _dangerFill,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: icon,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                // Cancel a little narrower than the action, per the mockup.
                Expanded(
                  flex: 4,
                  child: AppFlatPillButton(
                    label: AppLocalizations.of(context).commonCancel,
                    background: const Color(0xFFF2F4F9),
                    foreground: _ink,
                    onTap: () => Navigator.of(context).pop(false),
                    height: 48,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 5,
                  child: AppFlatPillButton(
                    label: confirmLabel,
                    background: _danger,
                    foreground: Colors.white,
                    onTap: () => Navigator.of(context).pop(true),
                    height: 48,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
