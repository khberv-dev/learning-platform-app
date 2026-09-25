import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/core/notifications/presentation/push_messaging_service.dart';
import 'package:student/core/notifications/presentation/unread_notifications_count_provider.dart';
import 'package:student/core/payments/presentation/purchase_watcher.dart';
import 'package:student/ui/courses/courses_page.dart';
import 'package:student/ui/courses/widget/purchase_success_dialog.dart';
import 'package:student/ui/home/home_page.dart';
import 'package:student/ui/main/widget/app_navbar.dart';
import 'package:student/ui/profile/profile_page.dart';
import 'package:student/ui/study/study_page.dart';

class AppScreen extends ConsumerStatefulWidget {
  static const path = '/app';

  const AppScreen({super.key});

  @override
  ConsumerState<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends ConsumerState<AppScreen>
    with WidgetsBindingObserver {
  /// Guards against two resume events overlapping the same refetch.
  bool _isCheckingPurchase = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // The shell is only reachable with a valid token, and registering the
    // device's push token needs one — so this is the first safe moment,
    // whether the student just logged in or the splash screen let them
    // straight through.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(pushMessagingProvider).start();
      ref.read(unreadNotificationsCountProvider.future).ignore();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkForPurchasedCourse();
  }

  /// Checkout finishes on the provider's site, so returning to the app is the
  /// only signal available. Refetch the library and see whether a course the
  /// student didn't own before has appeared.
  Future<void> _checkForPurchasedCourse() async {
    final watch = ref.read(purchaseWatchProvider);
    if (watch == null || _isCheckingPurchase) return;
    _isCheckingPurchase = true;

    try {
      ref.invalidate(myCoursesControllerProvider);
      final courses = await ref.read(myCoursesControllerProvider.future);

      final purchased = courses
          .where((c) => !watch.knownCourseIds.contains(c.courseId))
          .toList();

      // Nothing new yet — confirmation may still be pending, so keep watching
      // and check again on the next resume.
      if (purchased.isEmpty || !mounted) return;

      ref.read(purchaseWatchProvider.notifier).stop();
      await showPurchaseSuccessDialog(
        context,
        courseTitle: purchased.first.title,
        onOpenCourse: () => _openCourse(purchased.first),
      );
    } catch (_) {
      // A failed refetch just means no congratulation; the watch stays put.
    } finally {
      _isCheckingPurchase = false;
    }
  }

  void _openCourse(MyCourseEntity course) {
    if (!mounted) return;
    context.push('/course/${course.courseId}?owned=true');
  }

  @override
  Widget build(BuildContext context) {
    final navbarIndex = ref.watch(navbarControllerProvider);

    // The tabs live in an IndexedStack, so CoursesPage is never unmounted on
    // switching away from it — nothing naturally forces a refetch. Force one
    // explicitly on every switch back into it instead, so course data is
    // never served stale from an earlier visit.
    ref.listen<int>(navbarControllerProvider, (previous, next) {
      if (next == 1 && previous != next) {
        ref.invalidate(myCoursesControllerProvider);
        ref.invalidate(availableCoursesControllerProvider);
      }
    });

    return Scaffold(
      // Pages run to the bottom of the screen so the pill floats over their
      // content rather than over a strip of scaffold background. Scaffold
      // reports the navbar's height as MediaQuery bottom padding inside the
      // body, which each page adds to its scroll padding.
      extendBody: true,
      bottomNavigationBar: AppNavbar(
        current: navbarIndex,
        onItemClick: (index) =>
            ref.read(navbarControllerProvider.notifier).state = index,
      ),
      // Not SafeArea: the profile hero bleeds to the top edge, so each page
      // applies the top inset itself.
      body: IndexedStack(
        index: navbarIndex,
        children: const [HomePage(), CoursesPage(), StudyPage(), ProfilePage()],
      ),
    );
  }
}
