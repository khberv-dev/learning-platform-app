import 'package:flutter/material.dart';

/// Brand colours that sit outside the [ColorScheme] — used by the onboarding
/// artwork and the outlined button, which share the same dark teal ink.
abstract class AppColors {
  /// Dark teal used for headings and [AppButton.outlined] borders/labels.
  static const ink = Color(0xff1f4e5f);

  /// Deep green accent for emphasised words in headings. Darker than the
  /// theme primary so it stays readable on the pale onboarding sky.
  static const deepGreen = Color(0xff2f6b2e);

  /// Sky tone sampled from the top-centre of the onboarding artwork. The page
  /// sits on this so the band above the bottom-aligned artwork reads as more
  /// sky rather than a separate surface.
  static const onboardingSky = Color(0xffc8e1f5);

  /// Unfilled portion of [AppProgressBar].
  static const progressTrack = Color(0xffb6c3cb);

  /// Bottom of the survey's white-to-green page gradient.
  static const surveyGradientEnd = Color(0xff7cc04a);
}
