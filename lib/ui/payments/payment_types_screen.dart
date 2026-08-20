import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/core/payments/domain/entity/payment_type_entity.dart';
import 'package:student/core/payments/domain/usecase/use_select_payment_type.dart';
import 'package:student/core/payments/presentation/payment_request_controller.dart';
import 'package:student/core/payments/presentation/purchase_watcher.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/url_launcher.dart';
import 'package:student/shared/widget/app_empty_state.dart';
import 'package:student/shared/widget/back_icon_button.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/ui/main/app_screen.dart';
import 'package:student/utils/messenger.dart';

/// Picks how to pay for a course.
///
/// Opening the screen requests a payment for the chosen plan, which creates a
/// pending enrolment and returns the methods available. Choosing one attaches
/// it to that payment, drops the student back on the Courses tab, and hands
/// off to the provider's checkout page outside the app. Confirmation happens
/// elsewhere, so [PurchaseWatchController] records what was already owned and
/// [AppScreen] compares once the student returns.
/// Index of the Courses tab in [AppScreen]'s IndexedStack.
const _coursesTabIndex = 1;

class PaymentTypesScreen extends ConsumerStatefulWidget {
  static const path = '/payment-types';

  final String planId;

  const PaymentTypesScreen({super.key, required this.planId});

  @override
  ConsumerState<PaymentTypesScreen> createState() => _PaymentTypesScreenState();
}

class _PaymentTypesScreenState extends ConsumerState<PaymentTypesScreen> {
  /// Which tile is mid-request, so it can show progress and taps can't stack.
  String? _busyTypeId;

  Future<void> _choose(PaymentEntity payment, PaymentTypeEntity type) async {
    if (_busyTypeId != null) return;
    setState(() => _busyTypeId = type.id);

    try {
      final updated = await ref
          .read(useSelectPaymentTypeProvider)
          .call(paymentId: payment.id, paymentTypeId: type.id);

      // Prefer the URL the API echoes back; fall back to the listed one.
      final raw = updated.paymentType?.checkoutUrl ?? type.checkoutUrl;
      final uri = raw == null || raw.isEmpty ? null : Uri.tryParse(raw);
      if (!mounted) return;

      if (uri == null || !uri.hasScheme) {
        showErrorMessage(
          context,
          AppLocalizations.of(context).paymentNoLink(type.title),
        );
        return;
      }

      // Snapshot before leaving — this is what the courses list is diffed
      // against when the student comes back.
      final owned = await _ownedCourseIds();
      if (!mounted) return;

      ref
          .read(purchaseWatchProvider.notifier)
          .start(knownCourseIds: owned, planId: widget.planId);

      // This screen is about to be replaced, so the messenger has to be held
      // on to for any failure reported after the hand-off.
      final messenger = ScaffoldMessenger.of(context);
      final errorColour = Theme.of(context).colorScheme.error;
      // Read before the screen goes away; its context is unusable after.
      final openFailed = AppLocalizations.of(
        context,
      ).paymentOpenFailed(type.title);

      // Land on Courses first, so returning from the provider shows the
      // library rather than a stale checkout screen.
      ref.read(navbarControllerProvider.notifier).state = _coursesTabIndex;
      context.go(AppScreen.path);

      final opened = await ref.read(urlLauncherProvider)(uri);
      if (!opened) {
        ref.read(purchaseWatchProvider.notifier).stop();
        showErrorOn(messenger, openFailed, background: errorColour);
      }
    } catch (e) {
      if (mounted) showErrorMessage(context, apiErrorMessage(context, e));
    } finally {
      if (mounted) setState(() => _busyTypeId = null);
    }
  }

  /// Courses already owned, tolerating a list that hasn't loaded — a failure
  /// here would only mean the congratulation is skipped.
  Future<Set<String>> _ownedCourseIds() async {
    try {
      final courses = await ref.read(myCoursesControllerProvider.future);
      return courses.map((c) => c.courseId).toSet();
    } catch (_) {
      return const {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentRequestControllerProvider(widget.planId));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fa),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  const BackIconButton(),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SectionTitle(title: l10n.paymentTitle, fontSize: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(
                    paymentRequestControllerProvider(widget.planId),
                  );
                  await ref.read(
                    paymentRequestControllerProvider(widget.planId).future,
                  );
                },
                child: state.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _Placeholder(
                    title: l10n.paymentLoadFailed,
                    subtitle: apiErrorMessage(context, e),
                  ),
                  data: (request) {
                    if (request.paymentTypes.isEmpty) {
                      return _Placeholder(
                        title: l10n.paymentEmptyTitle,
                        subtitle: l10n.paymentEmptySubtitle,
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
                      ),
                      itemCount: request.paymentTypes.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, i) {
                        final type = request.paymentTypes[i];
                        return PaymentTypeTile(
                          type: type,
                          isBusy: _busyTypeId == type.id,
                          onTap: () => _choose(request.payment, type),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentTypeTile extends StatelessWidget {
  final PaymentTypeEntity type;
  final bool isBusy;
  final VoidCallback onTap;

  const PaymentTypeTile({
    super.key,
    required this.type,
    required this.onTap,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardEdge,
              offset: Offset(0, 5),
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          children: [
            _Icon(url: type.iconUrl, title: type.title),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                type.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (isBusy)
              const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                size: 28,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  static const _size = 48.0;

  final String? url;
  final String title;

  const _Icon({this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox.square(
        dimension: _size,
        child: url == null
            ? _fallback()
            : Image.network(
                url!,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() {
    return ColoredBox(
      color: AppColors.emptySurface,
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Keeps the placeholder pull-to-refreshable.
class _Placeholder extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Placeholder({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        AppEmptyState(
          imagePath: 'assets/images/no_comments_puppet.png',
          title: title,
          subtitle: subtitle,
        ),
      ],
    );
  }
}
