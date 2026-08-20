import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/l10n/app_localizations.dart';
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

/// A leaderboard position, written the way the language writes them.
///
/// English ordinals are a suffix on the number; Russian and Uzbek have no such
/// form and mark the position with № instead. That difference is grammar
/// rather than wording, so it lives here and not in the .arb files.
String rankLabel(Locale locale, int rank) =>
    locale.languageCode == 'en' ? ordinal(rank) : '№$rank';

class StatsRow extends ConsumerWidget {
  /// Position on the global leaderboard. The API doesn't expose one yet, so
  /// the caller passes null and the tile shows a placeholder.
  final int? globalRank;

  const StatsRow({super.key, this.globalRank});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context);

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
                label: l10n.homeStatsScores,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatChip(
                imagePath: 'assets/images/coin_chip.png',
                value: user != null ? formatNumber(user.coins) : '—',
                label: l10n.homeStatsCoins,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatChip(
                imagePath: 'assets/images/leaderboard_chip.png',
                value: globalRank != null
                    ? rankLabel(Localizations.localeOf(context), globalRank!)
                    : '—',
                label: l10n.homeStatsRanking,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
