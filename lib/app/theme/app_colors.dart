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

  /// Fill and outline of [AppPanel] — the home page's blue stat cards.
  static const panelFill = Color(0xffd4ebf9);
  static const panelBorder = Color(0xff4b9fd1);

  /// Amber track behind the streak week, and the ticks drawn on it.
  static const streakTrack = Color(0xfff2c14e);
  static const streakTick = Color(0xffb07d1a);

  /// Dark teal panel the home page's library and live-lesson sections sit on.
  static const librarySurface = Color(0xff084f62);

  /// Blue promo card, and the button colour used on the green one.
  static const promoBlue = Color(0xff3d9ac8);

  /// Bottom of the survey's white-to-green page gradient.
  static const surveyGradientEnd = Color(0xff7cc04a);
}
