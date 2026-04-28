import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/core/domain/user/usecase/use_get_me.dart';
import 'package:student/core/presentation/user/current_user_provider.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/main/app_screen.dart';
import 'package:student/ui/startup/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const path = '/';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController logoAnimationController, titleAnimationController;
  late Animation<double> logoRotateAnimation,
      logoScaleAnimation,
      titleTranslateAnimation,
      titleOpacityAnimation;

  @override
  void initState() {
    super.initState();

    const logoAnimationDuration = Duration(seconds: 2);

    logoAnimationController = AnimationController(
      vsync: this,
      duration: logoAnimationDuration,
    );

    titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, milliseconds: 500),
    );

    logoRotateAnimation = Tween(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: logoAnimationController, curve: Curves.easeInOut),
    );

    logoScaleAnimation = Tween(begin: 8.0, end: 1.0).animate(
      CurvedAnimation(parent: logoAnimationController, curve: Curves.easeInOut),
    );

    titleTranslateAnimation = Tween(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: titleAnimationController, curve: Curves.easeOut),
    );

    titleOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: titleAnimationController, curve: Curves.easeOut),
    );

    logoAnimationController.forward();

    Future.delayed(logoAnimationDuration, () {
      titleAnimationController.forward();
    });

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Let the full splash animation play before navigating.
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    final token = await ref.read(tokenStorageProvider).getAccessToken();
    if (!mounted) return;

    if (token == null) {
      context.go(OnboardingScreen.path);
      return;
    }

    try {
      final user = await ref.read(useGetMeProvider).call();
      if (!mounted) return;
      ref.read(currentUserProvider.notifier).state = user;
      context.go(AppScreen.path);
    } catch (_) {
      if (!mounted) return;
      context.go(LoginScreen.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: logoAnimationController,
              builder: (context, _) => Transform(
                alignment: AlignmentGeometry.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(logoRotateAnimation.value)
                  ..multiply(
                    Matrix4.diagonal3Values(
                      logoScaleAnimation.value,
                      logoScaleAnimation.value,
                      1,
                    ),
                  ),
                child: Image.asset('assets/images/brand.png', width: 150),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: titleAnimationController,
              builder: (context, _) => Opacity(
                opacity: titleOpacityAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, titleTranslateAnimation.value),
                  child: Text(
                    'Welcome to iTeach!',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    logoAnimationController.dispose();
    titleAnimationController.dispose();
    super.dispose();
  }
}
