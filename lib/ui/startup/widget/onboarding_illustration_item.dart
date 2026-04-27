import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/domain/startup/model/illustration.dart';

class OnboardingIllustrationItem extends StatelessWidget {
  final Illustration illustration;

  const OnboardingIllustrationItem({super.key, required this.illustration});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          illustration.imagePath,
          width: double.infinity,
          height: 290,
          fit: BoxFit.cover,
        ),
        SizedBox(height: AppSpacing.lg),
        Text(
          illustration.title,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            illustration.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
