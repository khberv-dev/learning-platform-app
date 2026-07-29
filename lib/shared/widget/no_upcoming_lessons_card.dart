import 'package:flutter/material.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';

/// Empty state for the scheduled-lessons lists — artwork with the headline
/// laid over it. Shared by the home page and the courses page's live tab.
class NoUpcomingLessonsCard extends StatelessWidget {
  final double height;

  const NoUpcomingLessonsCard({super.key, this.height = 190});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/no_upcoming_lessons_background.png',
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          // Sits over the artwork's darkest area, so white reads cleanly.
          const Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Text(
              'No upcoming lessons',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
