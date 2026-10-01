import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/core/user/presentation/streak_provider.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/ui/home/widget/home_learning_cards.dart';
import 'package:student/ui/home/widget/home_topbar.dart';
import 'package:student/ui/home/widget/streak_card.dart';

/// Tab index of Courses in the navbar, where the carousel's "See all" leads.
const _coursesTabIndex = 1;

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider).value;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: AppSpacing.xxl + MediaQuery.paddingOf(context).top,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeTopbar(),
          // The streak card adds room of its own for its mascot, which
          // rises above the card.
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: StreakCard(days: streak?.currentStreak ?? 0),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [HomeCourseCards(), HomePracticeTiles()],
            ),
          ),
          // Full width, so the carousel scrolls edge to edge.
          HomeCoursesCarousel(
            onSeeAll: () => ref.read(navbarControllerProvider.notifier).state =
                _coursesTabIndex,
          ),
          // Clear of the floating navbar.
          SizedBox(
            height: AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
          ),
        ],
      ),
    );
  }
}
