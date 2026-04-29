import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/ui/home/widget/stat_card.dart';
import 'package:student/utils/lib.dart';

class StatsRow extends ConsumerWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.bolt,
              iconColor: const Color(0xFFF59E0B),
              value: '0',
              label: 'Day Streak',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.star,
              iconColor: const Color(0xFF18C96A),
              value: user != null ? formatNumber(user.points) : '—',
              label: 'Points',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.workspace_premium,
              iconColor: const Color(0xFF2979FF),
              value: user?.level ?? '—',
              label: 'Level',
            ),
          ),
        ],
      ),
    );
  }
}
