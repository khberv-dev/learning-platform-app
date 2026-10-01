import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/core/user/domain/usecase/use_get_me.dart';
import 'package:student/core/notifications/presentation/unread_notifications_count_provider.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
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

  /// Everything the page shows: the student (points, coins, photo), the
  /// streak, unread notifications, their courses and the carousel.
  static Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(streakProvider);
    ref.invalidate(unreadNotificationsCountProvider);
    ref.invalidate(myCoursesControllerProvider);
    ref.invalidate(availableCoursesControllerProvider);
    await Future.wait<void>([
      _reloadUser(ref),
      ref.read(streakProvider.future).then((_) {}, onError: (_) {}),
      ref
          .read(myCoursesControllerProvider.future)
          .then((_) {}, onError: (_) {}),
      ref
          .read(availableCoursesControllerProvider.future)
          .then((_) {}, onError: (_) {}),
    ]);
  }

  /// The student comes from `/me`, held in [currentUserProvider] rather than
  /// a fetching provider, so it's reloaded by hand. A failure keeps what's
  /// on screen.
  static Future<void> _reloadUser(WidgetRef ref) async {
    try {
      final user = await ref.read(useGetMeProvider).call();
      ref.read(currentUserProvider.notifier).state = user;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider).value;
    return RefreshIndicator(
      // Below the status bar, where the page's content starts.
      edgeOffset: MediaQuery.paddingOf(context).top,
      onRefresh: () => _refresh(ref),
      child: SingleChildScrollView(
        // Pull-to-refresh works even when the page doesn't fill the screen.
        physics: const AlwaysScrollableScrollPhysics(),
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
              onSeeAll: () =>
                  ref.read(navbarControllerProvider.notifier).state =
                      _coursesTabIndex,
            ),
            // Clear of the floating navbar.
            SizedBox(
              height: AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
            ),
          ],
        ),
      ),
    );
  }
}
