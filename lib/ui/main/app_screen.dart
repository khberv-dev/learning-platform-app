import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/ui/courses/courses_page.dart';
import 'package:student/ui/home/home_page.dart';
import 'package:student/ui/main/widget/app_navbar.dart';
import 'package:student/ui/tutors/tutors_page.dart';

class AppScreen extends ConsumerWidget {
  static const path = '/app';

  const AppScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navbarIndex = ref.watch(navbarControllerProvider);

    void onNavItemClick(int index) {
      ref.read(navbarControllerProvider.notifier).state = index;
    }

    return Scaffold(
      bottomNavigationBar: AppNavbar(
        current: navbarIndex,
        onItemClick: onNavItemClick,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: navbarIndex,
          children: const [
            HomePage(),
            CoursesPage(),
            TutorsPage(),
            SizedBox(), // Profile tab placeholder
          ],
        ),
      ),
    );
  }
}
