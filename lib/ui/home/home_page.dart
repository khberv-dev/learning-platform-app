import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/ui/home/widget/ai_assessment_card.dart';
import 'package:student/ui/home/widget/home_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    void onNotificationClick() {}

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          HomeHeader(onNotificationClick: onNotificationClick),
          SizedBox(height: AppSpacing.md),
          AiAssessmentCard(),
        ],
      ),
    );
  }
}
