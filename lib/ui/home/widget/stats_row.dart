import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/ui/home/widget/stat_card.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.bolt,
              iconColor: const Color(0xFFF59E0B),
              value: '12',
              label: 'Day Streak',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.star,
              iconColor: const Color(0xFF18C96A),
              value: '1,240',
              label: 'Points',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.workspace_premium,
              iconColor: const Color(0xFF2979FF),
              value: 'B1',
              label: 'Level',
            ),
          ),
        ],
      ),
    );
  }
}
