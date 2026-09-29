import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The redesign's back button: a pale rounded square rather than the older
/// white circle of `BackIconButton`.
class AuthBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const AuthBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F5FB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/arrow_left.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF111827),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
