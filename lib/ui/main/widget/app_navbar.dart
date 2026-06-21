import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _SvgNavItem {
  final String label;
  final String iconPath;

  const _SvgNavItem({required this.label, required this.iconPath});

  BottomNavigationBarItem build(BuildContext context) {
    return BottomNavigationBarItem(
      label: label,
      icon: SvgPicture.asset(
        iconPath,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.onSurfaceVariant,
          BlendMode.srcIn,
        ),
      ),
      activeIcon: SvgPicture.asset(
        iconPath,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

BottomNavigationBarItem _iconNavItem({
  required BuildContext context,
  required String label,
  required IconData icon,
}) {
  return BottomNavigationBarItem(
    label: label,
    icon: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
    activeIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
  );
}

class AppNavbar extends StatelessWidget {
  final int current;
  final bool showChat;
  final Function(int) onItemClick;

  const AppNavbar({
    super.key,
    required this.current,
    required this.onItemClick,
    this.showChat = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _SvgNavItem(label: 'Home', iconPath: 'assets/icons/home.svg')
          .build(context),
      _SvgNavItem(label: 'Course', iconPath: 'assets/icons/grid.svg')
          .build(context),
      if (showChat)
        _iconNavItem(
          context: context,
          label: 'Chat',
          icon: Icons.chat_bubble_outline_rounded,
        )
      else
        _SvgNavItem(label: 'Mentor', iconPath: 'assets/icons/student.svg')
            .build(context),
      _SvgNavItem(label: 'Profile', iconPath: 'assets/icons/profile.svg')
          .build(context),
    ];

    return BottomNavigationBar(
      items: items,
      currentIndex: current,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      onTap: onItemClick,
    );
  }
}
