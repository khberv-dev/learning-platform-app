import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/ui/home/widget/stat_chip.dart';
import 'package:student/utils/lib.dart';

/// Turns 1, 2, 3, 11 into 1st, 2nd, 3rd, 11th.
String ordinal(int n) {
  if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}

class StatsRow extends ConsumerWidget {
  /// Position on the global leaderboard. The API doesn't expose one yet, so
  /// the caller passes null and the tile shows a placeholder.
  final int? globalRank;

  const StatsRow({super.key, this.globalRank});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StatChip(
                imagePath: 'assets/images/score_chip.png',
                value: user != null ? formatNumber(user.points) : '—',
                label: 'Scores',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatChip(
                imagePath: 'assets/images/coin_chip.png',
                value: user != null ? formatNumber(user.coins) : '—',
                label: 'Coins',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatChip(
                imagePath: 'assets/images/leaderboard_chip.png',
                value: globalRank != null ? ordinal(globalRank!) : '—',
                label: 'Global ranking',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
