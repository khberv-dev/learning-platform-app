import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    final logoAnimationDuration = Duration(seconds: 2);

    logoAnimationController = AnimationController(
      vsync: this,
      duration: logoAnimationDuration,
    );

    titleAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1, milliseconds: 500),
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

    Future.delayed(Duration(seconds: 4), () async {
      context.go(OnboardingScreen.path);
    });
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
            SizedBox(height: 20),
            AnimatedBuilder(
              animation: titleAnimationController,
              builder: (context, _) => Opacity(
                opacity: titleOpacityAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, titleTranslateAnimation.value),
                  child: Text(
                    "Welcome to iTeach!",
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
}
