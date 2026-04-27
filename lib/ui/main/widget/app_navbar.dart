import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _AppNavbarItem {
  final String label;
  final String iconPath;

  const _AppNavbarItem({required this.label, required this.iconPath});

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

class AppNavbar extends StatelessWidget {
  final int current;
  final Function(int) onItemClick;

  const AppNavbar({
    super.key,
    required this.current,
    required this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _AppNavbarItem(
        label: "Home",
        iconPath: 'assets/icons/home.svg',
      ).build(context),
      _AppNavbarItem(
        label: "Course",
        iconPath: 'assets/icons/grid.svg',
      ).build(context),
      _AppNavbarItem(
        label: "Mentor",
        iconPath: 'assets/icons/student.svg',
      ).build(context),
      _AppNavbarItem(
        label: "Profile",
        iconPath: 'assets/icons/profile.svg',
      ).build(context),
    ];

    return BottomNavigationBar(
      items: items,
      currentIndex: current,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      onTap: onItemClick,
    );
  }
}
