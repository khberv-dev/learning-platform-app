import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class BackIconButton extends StatelessWidget {
  final VoidCallback? onTap;

  const BackIconButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap ?? () => context.pop(),
      icon: SvgPicture.asset(
        'assets/icons/arrow_left.svg',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        fixedSize: const Size(40, 40),
      ),
    );
  }
}
