import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:student/ui/shared/widget/app_header.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onNotificationClick;

  const HomeHeader({super.key, required this.onNotificationClick});

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Good morning 👋",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                "John Doe",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onNotificationClick,
            icon: SvgPicture.asset('assets/icons/bell.svg'),
          ),
        ],
      ),
    );
  }
}
