import 'package:flutter/material.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_button.dart';

/// Congratulates the student on a course that appeared after checkout.
Future<void> showPurchaseSuccessDialog(
  BuildContext context, {
  required String courseTitle,
  VoidCallback? onOpenCourse,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/no_course_puppet.png',
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppLocalizations.of(ctx).purchaseSuccessTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppLocalizations.of(ctx).purchaseSuccessBody(courseTitle),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff8a949b),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.filled(
              label: AppLocalizations.of(ctx).purchaseSuccessButton,
              fontSize: 15,
              height: 48,
              onTap: () {
                Navigator.of(ctx).pop();
                onOpenCourse?.call();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
