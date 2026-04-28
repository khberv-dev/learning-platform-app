import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationIconButton extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationIconButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: SvgPicture.asset(
        'assets/icons/bell.svg',
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(Color(0xFF374151), BlendMode.srcIn),
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        fixedSize: const Size(40, 40),
      ),
    );
  }
}
