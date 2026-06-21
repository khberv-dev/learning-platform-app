import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/chat/presentation/chat_rooms_controller.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/ui/chat/chat_room_screen.dart';
import 'package:student/ui/courses/courses_page.dart';
import 'package:student/ui/home/home_page.dart';
import 'package:student/ui/main/widget/app_navbar.dart';
import 'package:student/ui/profile/profile_page.dart';
import 'package:student/ui/tutors/tutors_page.dart';

class AppScreen extends ConsumerWidget {
  static const path = '/app';

  const AppScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      bottomNavigationBar: AppNavbar(
        current: navbarIndex,
        showChat: showChat,
        onItemClick: onNavItemClick,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: navbarIndex,
          children: const [
            HomePage(),
            CoursesPage(),
            TutorsPage(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}
