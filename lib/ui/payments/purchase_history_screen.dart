import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/enrollments/domain/entity/enrollment_history_entity.dart';
import 'package:student/core/enrollments/presentation/enrollment_history_controller.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/core/payments/presentation/payments_history_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_empty_state.dart';
import 'package:student/shared/widget/back_icon_button.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/utils/date_format.dart';
import 'package:student/utils/lib.dart';
import 'package:student/utils/messenger.dart';

/// A student's money history: what they've paid, and what enrolment periods
/// those payments unlocked. Two flat lists rather than one, since a payment
/// and its resulting enrolment period are different things to scan for.
class PurchaseHistoryScreen extends StatelessWidget {
  static const path = '/purchase-history';

  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xfff6f7fa),
        body: SafeArea(
          child: Column(
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
                      child: SectionTitle(
                        title: l10n.purchaseHistoryTitle,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: const Color(0xff9aa5ad),
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  Tab(text: l10n.purchaseHistoryPayments),
                  Tab(text: l10n.purchaseHistoryEnrollments),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [_PaymentsTab(), _EnrollmentsTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentsHistoryControllerProvider);
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(paymentsHistoryControllerProvider.future),
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorList(message: apiErrorMessage(context, e)),
        data: (payments) {
          if (payments.isEmpty) {
            return _EmptyList(title: l10n.purchaseHistoryEmptyPayments);
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: payments.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, i) => _PaymentTile(payment: payments[i]),
          );
        },
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentEntity payment;

  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dt = DateTime.tryParse(payment.createdAt);

    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.planTitle ?? payment.courseTitle ?? '—',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.plansPrice(formatNumber(payment.amount)),
                  style: const TextStyle(
                    color: Color(0xff6b7280),
                    fontSize: 13,
                  ),
                ),
                if (dt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    formatShortDate(context, dt),
                    style: const TextStyle(
                      color: Color(0xff9ca3af),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _StatusChip(status: payment.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final PaymentStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      PaymentStatus.paid => (
        l10n.purchaseHistoryStatusPaid,
        const Color(0xff18c96a),
      ),
      PaymentStatus.cancelled => (
        l10n.purchaseHistoryStatusCancelled,
        const Color(0xffef4444),
      ),
      PaymentStatus.created => (
        l10n.purchaseHistoryStatusCreated,
        const Color(0xfff59e0b),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EnrollmentsTab extends ConsumerWidget {
  const _EnrollmentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(enrollmentHistoryControllerProvider);
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(enrollmentHistoryControllerProvider.future),
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorList(message: apiErrorMessage(context, e)),
        data: (enrollments) {
          if (enrollments.isEmpty) {
            return _EmptyList(title: l10n.purchaseHistoryEmptyEnrollments);
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: enrollments.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, i) => _EnrollmentTile(entry: enrollments[i]),
          );
        },
      ),
    );
  }
}

class _EnrollmentTile extends StatelessWidget {
  final EnrollmentHistoryEntity entry;

  const _EnrollmentTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final start = entry.start;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.courseTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.plansPrice(entry.purchaseAmount),
            style: const TextStyle(color: Color(0xff6b7280), fontSize: 13),
          ),
          if (start != null) ...[
            const SizedBox(height: 2),
            Text(
              formatShortDate(context, start),
              style: const TextStyle(color: Color(0xff9ca3af), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  final String title;

  const _EmptyList({required this.title});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppEmptyState(
          imagePath: 'assets/images/no_comments_puppet.png',
          title: title,
        ),
      ],
    );
  }
}

class _ErrorList extends StatelessWidget {
  final String message;

  const _ErrorList({required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppEmptyState(
          imagePath: 'assets/images/no_comments_puppet.png',
          title: l10n.purchaseHistoryLoadFailed,
          subtitle: message,
        ),
      ],
    );
  }
}
