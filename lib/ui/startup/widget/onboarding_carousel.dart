import 'package:flutter/material.dart';
import 'package:student/core/startup/domain/model/illustration.dart';
import 'package:student/ui/startup/widget/onboarding_illustration_item.dart';

class OnboardingCarousel extends StatelessWidget {
  final PageController controller;
  final List<Illustration> items;

  const OnboardingCarousel({
    super.key,
    required this.controller,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: items.length,
      itemBuilder: (_, index) =>
          OnboardingIllustrationItem(illustration: items[index]),
    );
  }
}
