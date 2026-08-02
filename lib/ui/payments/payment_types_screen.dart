import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/core/payments/domain/entity/payment_type_entity.dart';
import 'package:student/core/payments/domain/usecase/use_select_payment_type.dart';
import 'package:student/core/payments/presentation/payment_request_controller.dart';
import 'package:student/shared/url_launcher.dart';
import 'package:student/shared/widget/app_empty_state.dart';
import 'package:student/shared/widget/back_icon_button.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/utils/messenger.dart';

/// Picks how to pay for a course.
///
/// Opening the screen requests a payment, which creates a pending enrolment
/// and returns the methods available. Choosing one attaches it to that payment
/// and hands off to the provider's checkout page outside the app; an admin
/// confirms the payment afterwards.
class PaymentTypesScreen extends ConsumerStatefulWidget {
  static const path = '/payment-types';

  final String courseId;

  const PaymentTypesScreen({super.key, required this.courseId});

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
        showErrorMessage(context, '${type.title} has no checkout link yet');
        return;
      }

      final opened = await ref.read(urlLauncherProvider)(uri);
      if (!opened && mounted) {
        showErrorMessage(context, "Couldn't open ${type.title}");
      }
    } catch (e) {
      if (mounted) showErrorMessage(context, apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busyTypeId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentRequestControllerProvider(widget.courseId));

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fa),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  BackIconButton(),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SectionTitle(title: 'Payment method', fontSize: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(
                    paymentRequestControllerProvider(widget.courseId),
                  );
                  await ref.read(
                    paymentRequestControllerProvider(widget.courseId).future,
                  );
                },
                child: state.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _Placeholder(
                    title: "Couldn't start the payment",
                    subtitle: apiErrorMessage(e),
                  ),
                  data: (request) {
                    if (request.paymentTypes.isEmpty) {
                      return const _Placeholder(
                        title: 'No payment methods',
                        subtitle: 'None are set up yet',
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
