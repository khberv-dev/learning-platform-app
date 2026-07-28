import 'package:flutter/material.dart';
import 'package:student/app/theme/app_colors.dart';

/// White-to-green page wash used by the onboarding survey and skill quiz.
class AppGradientBackground extends StatelessWidget {
  final Widget child;

  const AppGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, AppColors.surveyGradientEnd],
          stops: [0.18, 1],
        ),
      ),
      child: child,
    );
  }
}
