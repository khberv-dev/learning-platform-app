import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/subscriptions/domain/entity/subscription_entity.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/profile/widget/profile_icons.dart';
import 'package:student/utils/date_format.dart';

const _ink = Color(0xFF15141A);
const _muted = Color(0xFF6D737E);
const _green = Color(0xFF78C93C);
const _blue = Color(0xFF4A9FE0);

/// Which of the three plan cards the profile shows.
sealed class PlanStatus {
  const PlanStatus();

  /// Current subscriptions first; failing that, the one that ended last;
  /// failing that, none.
  factory PlanStatus.of(List<SubscriptionEntity> subscriptions, DateTime now) {
    final current = subscriptions.where((s) => s.isCurrentAt(now)).toList()
      ..sort((a, b) => a.end.compareTo(b.end));
    if (current.isNotEmpty) return PlanActive(current);
    if (subscriptions.isEmpty) return const PlanNone();
    final latest = subscriptions.reduce((a, b) => a.end.isAfter(b.end) ? a : b);
    return PlanExpired(latest);
  }
}

/// One or more subscriptions still running, soonest to end first.
class PlanActive extends PlanStatus {
  final List<SubscriptionEntity> subscriptions;
  const PlanActive(this.subscriptions);
}

/// Never subscribed.
class PlanNone extends PlanStatus {
  const PlanNone();
}

/// Every subscription has run out; [latest] ended most recently.
class PlanExpired extends PlanStatus {
  final SubscriptionEntity latest;
  const PlanExpired(this.latest);
}

/// A running subscription: a blue card with the course, an "Active" badge
/// and the end date.
class ActivePlanCard extends StatelessWidget {
  final SubscriptionEntity subscription;

  const ActivePlanCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5CB3F6), Color(0xFF4AA2EC)],
        ),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: ProfileIcons.crown(size: 22, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.profileCurrentPlan,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subscription.course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.profilePlanActive,
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.profilePlanEnds,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  formatMediumDate(context, subscription.end),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The white card for no plan, or an expired one: a badge, a title and
/// body, and a green button.
class PlanPromptCard extends StatelessWidget {
  final Widget badge;
  final Color badgeFill;
  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onTap;

  const PlanPromptCard({
    super.key,
    required this.badge,
    required this.badgeFill,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onTap,
  });

  /// Never subscribed: a green crown and a way to pick a plan.
  factory PlanPromptCard.none(
    BuildContext context, {
    required VoidCallback onChoose,
  }) {
    final l10n = AppLocalizations.of(context);
    return PlanPromptCard(
      key: const ValueKey('plan-none'),
      badge: ProfileIcons.crown(size: 22, color: _green),
      badgeFill: const Color(0xFFE8F7DC),
      title: l10n.profileNoPlanTitle,
      body: l10n.profileNoPlanBody,
      buttonLabel: l10n.profileChoosePlan,
      onTap: onChoose,
    );
  }

  /// Every plan has run out: an orange warning and a way to renew.
  factory PlanPromptCard.expired(
    BuildContext context, {
    required SubscriptionEntity latest,
    required VoidCallback onRenew,
  }) {
    final l10n = AppLocalizations.of(context);
    return PlanPromptCard(
      key: const ValueKey('plan-expired'),
      badge: const Icon(
        Icons.error_rounded,
        size: 24,
        color: Color(0xFFF5A623),
      ),
      badgeFill: const Color(0xFFFDEFD9),
      title: l10n.profilePlanExpired(latest.course.title),
      body: l10n.profilePlanEndedOn(formatMediumDate(context, latest.end)),
      buttonLabel: l10n.profileRenewPlan,
      onTap: onRenew,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeFill,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: badge,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppFlatPillButton(
            label: buttonLabel,
            background: _green,
            foreground: Colors.white,
            onTap: onTap,
            height: 48,
            fontSize: 15,
          ),
        ],
      ),
    );
  }
}
