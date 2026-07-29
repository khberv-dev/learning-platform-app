import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/ui/home/widget/ai_test_card.dart';
import 'package:student/ui/home/widget/balance_card.dart';
import 'package:student/ui/home/widget/continue_learning_card.dart';
import 'package:student/ui/home/widget/home_topbar.dart';
import 'package:student/ui/home/widget/live_session_card.dart';
import 'package:student/ui/home/widget/speaking_partner_card.dart';
import 'package:student/ui/home/widget/stats_row.dart';
import 'package:student/ui/home/widget/streak_card.dart';
import 'package:student/ui/home/widget/upcoming_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(currentUserProvider)?.balance ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeTopbar(),
          const SizedBox(height: AppSpacing.xxl),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              "You're on fire",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // TODO(api): streak length and the week's completed days aren't on
          // /me yet, so these are placeholders.
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: StreakCard(days: 0, week: StreakCard.emptyWeek),
          ),
          const SizedBox(height: AppSpacing.md),
          const StatsRow(),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: BalanceCard(balance: balance),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Everything below sits on a dark teal panel. The navbar clearance
          // lives inside its padding rather than on the scroll view, so the
          // panel colour runs under the floating pill instead of leaving a
          // strip of scaffold background there.
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.librarySurface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            padding: EdgeInsets.only(
              top: AppSpacing.xl,
              bottom: AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContinueLearningCard(),
                SizedBox(height: AppSpacing.md),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: AiTestCard(),
                ),
                SizedBox(height: AppSpacing.md),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: SpeakingPartnerCard(),
                ),
                SizedBox(height: AppSpacing.xl),
                LiveSessionCard(),
                SizedBox(height: AppSpacing.lg),
                UpcomingSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
