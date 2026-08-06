import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/plans/domain/entity/plan_entity.dart';
import 'package:student/core/plans/presentation/course_plans_controller.dart';
import 'package:student/shared/widget/app_empty_state.dart';
import 'package:student/shared/widget/back_icon_button.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/ui/payments/payment_types_screen.dart';
import 'package:student/utils/lib.dart';
import 'package:student/utils/messenger.dart';

/// Picks which tariff to buy a course on. A course carries no price of its
/// own — each plan sets one, for a given number of months.
class PlansScreen extends ConsumerWidget {
  static const path = '/course-plans';

  final String courseId;

  const PlansScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(coursePlansControllerProvider(courseId));

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
                    child: SectionTitle(title: 'Choose a plan', fontSize: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(coursePlansControllerProvider(courseId));
                  await ref.read(
                    coursePlansControllerProvider(courseId).future,
                  );
                },
                child: state.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _Placeholder(
                    title: "Couldn't load the plans",
                    subtitle: apiErrorMessage(e),
                  ),
                  data: (plans) {
                    if (plans.isEmpty) {
                      return const _Placeholder(
                        title: 'No plans yet',
                        subtitle: 'This course is not on sale at the moment',
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
                      itemCount: plans.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, i) => PlanCard(
                        plan: plans[i],
                        // The payment is opened against the plan; the API
                        // derives the course from it.
                        onTap: () => context.push(
                          '${PaymentTypesScreen.path}?planId=${plans[i].id}',
                        ),
                      ),
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

class PlanCard extends StatelessWidget {
  final PlanEntity plan;
  final VoidCallback onTap;

  const PlanCard({super.key, required this.plan, required this.onTap});

  String get _duration => plan.month == 1 ? '1 month' : '${plan.month} months';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    plan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _duration,
                    style: const TextStyle(
                      color: Color(0xff8a949b),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (plan.hasMentor) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const _MentorChip(),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              "${formatNumber(plan.price)} so'm",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
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

class _MentorChip extends StatelessWidget {
  const _MentorChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.round),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: const Text(
        'With mentor',
        style: TextStyle(
          color: AppColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w700,
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
