import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/plans/plans_screen.dart';
import 'package:student/utils/messenger.dart';

/// What a lesson or its tasks show when they fail to load. A 403 means the
/// student isn't enrolled in the course — that gets a prompt to buy a plan
/// rather than an error; anything else shows the error.
class LessonLoadError extends StatelessWidget {
  final Object error;
  final String courseId;

  const LessonLoadError({
    super.key,
    required this.error,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notEnrolled = isForbidden(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (notEnrolled) ...[
              const Icon(
                Icons.lock_rounded,
                size: 48,
                color: Color(0xFFA5A6B9),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.courseNotEnrolledTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF15141A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(
              notEnrolled
                  ? l10n.courseNotEnrolledMessage
                  : apiErrorMessage(context, error),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6D737E),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (notEnrolled) ...[
              const SizedBox(height: AppSpacing.lg),
              AppFlatPillButton(
                label: l10n.courseChoosePlan,
                background: const Color(0xFF78C93C),
                foreground: Colors.white,
                onTap: () =>
                    context.push('${PlansScreen.path}?courseId=$courseId'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
