import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/chat/presentation/chat_rooms_controller.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/core/notifications/presentation/push_messaging_service.dart';
import 'package:student/core/notifications/presentation/unread_notifications_count_provider.dart';
import 'package:student/core/payments/presentation/purchase_watcher.dart';
import 'package:student/ui/chat/chat_room_screen.dart';
import 'package:student/ui/courses/courses_page.dart';
import 'package:student/ui/courses/widget/purchase_success_dialog.dart';
import 'package:student/ui/home/home_page.dart';
import 'package:student/ui/main/widget/app_navbar.dart';
import 'package:student/ui/profile/profile_page.dart';
import 'package:student/ui/tutors/tutors_page.dart';

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
    final showChat = ref.watch(hasChatRoomsProvider).value ?? false;

    void onNavItemClick(int index) {
      if (showChat && index == 2) {
        final rooms = ref.read(chatRoomsProvider).value;
        final room = rooms?.firstOrNull;
        if (room == null) return;
        context.push('${ChatRoomScreen.path}?roomId=${room.id}');
        return;
      }
      ref.read(navbarControllerProvider.notifier).state = index;
    }

    return Scaffold(
      // Pages run to the bottom of the screen so the pill floats over their
      // content rather than over a strip of scaffold background. Scaffold
      // reports the navbar's height as MediaQuery bottom padding inside the
      // body, which each page adds to its scroll padding.
      extendBody: true,
      bottomNavigationBar: AppNavbar(
        current: navbarIndex,
        showChat: showChat,
        onItemClick: onNavItemClick,
      ),
      // Not SafeArea: the profile hero bleeds to the top edge, so each page
      // applies the top inset itself.
      body: IndexedStack(
        index: navbarIndex,
        children: const [
          HomePage(),
          CoursesPage(),
          TutorsPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}
