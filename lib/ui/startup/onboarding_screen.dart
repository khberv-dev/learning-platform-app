import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/domain/startup/model/illustration.dart';
import 'package:student/ui/shared/widget/dot_progress.dart';
import 'package:student/ui/startup/welcome_screen.dart';
import 'package:student/ui/startup/widget/onboarding_carousel.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  static const path = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int carouselCurrentIndex = 0;

  final carouselController = PageController();

  @override
  void initState() {
    super.initState();

    carouselController.addListener(() {
      setState(() {
        carouselCurrentIndex = carouselController.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final illustrations = [
      Illustration(
        title: "Master English\nWith Confidence",
        description:
            "Learn at your own pace with interactive lessons designed for real-world communication",
        imagePath: 'assets/images/illustration_1.png',
      ),
      Illustration(
        title: "Fun & Interactive\nLearning",
        description:
            "Gamified quizzes, speaking challenges, and live feedback keep you motivated every day",
        imagePath: 'assets/images/illustration_2.png',
      ),
      Illustration(
        title: "Track Your\nProgress Daily",
        description:
            "Learn at your own pace with interactive lessons designed for real-world communication",
        imagePath: 'assets/images/illustration_3.png',
      ),
    ];

    void onSkipClick() {
      context.go(WelcomeScreen.path);
    }

    void onNextClick() {
      if (carouselCurrentIndex < illustrations.length - 1) {
        carouselController.animateToPage(
          carouselCurrentIndex + 1,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      } else {
        onSkipClick();
      }
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: 450,
              child: OnboardingCarousel(
                controller: carouselController,
                items: illustrations,
              ),
            ),
            DotProgress(
              length: illustrations.length,
              current: carouselCurrentIndex,
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onNextClick,
                      child: Text("Next"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onSkipClick,
                      child: Text("Skip"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    carouselController.dispose();

    super.dispose();
  }
}
