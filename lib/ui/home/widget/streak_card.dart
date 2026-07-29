import 'package:flutter/material.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/shared/widget/app_panel.dart';
import 'package:student/utils/lib.dart';

/// Day initials, Monday first, matching the order of [StreakCard.week].
const _weekdayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class StreakCard extends StatelessWidget {
  /// A week with nothing completed — the placeholder until the API reports
  /// real streak data.
  static const emptyWeek = [false, false, false, false, false, false, false];

  /// Consecutive days practised.
  final int days;

  /// Seven flags, Monday first, marking which days of this week are done.
  /// Shorter lists simply leave the trailing days unticked.
  final List<bool> week;

  const StreakCard({super.key, required this.days, required this.week});

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        0,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/fire_chip.png', height: 34),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${formatNumber(days)} day',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  "Don't forget me!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _WeekStrip(week: week),
              ],
            ),
          ),
          Image.asset(
            'assets/images/streak_puppet.png',
            width: 118,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final List<bool> week;

  const _WeekStrip({required this.week});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (final initial in _weekdayInitials)
              Expanded(
                child: Text(
                  initial,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xff8fa3b0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.streakTrack,
            borderRadius: BorderRadius.circular(AppRadius.round),
          ),
          // Always seven cells so the ticks stay under their day initials,
          // however many flags the caller passed.
          child: Row(
            children: [
              for (var i = 0; i < _weekdayInitials.length; i++)
                Expanded(
                  child: i < week.length && week[i]
                      ? const Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: AppColors.streakTick,
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
