import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/profile/widget/profile_icons.dart';
import 'package:student/utils/lib.dart';

const _ink = Color(0xFF15141A);
const _muted = Color(0xFF6D737E);

/// Streak, XP, coins and leaderboard rank as four white tiles, two by two.
class ProfileStatsGrid extends StatelessWidget {
  final int streakDays;
  final int points;
  final int coins;

  /// Leaderboard position. The API has none yet, so it shows a dash.
  final int? rank;

  const ProfileStatsGrid({
    super.key,
    required this.streakDays,
    required this.points,
    required this.coins,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rank = this.rank;

    Widget row(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: b),
        ],
      ),
    );

    return Column(
      children: [
        row(
          _StatTile(
            icon: const Icon(
              Icons.bolt_rounded,
              size: 20,
              color: Color(0xFFF5A623),
            ),
            fill: const Color(0xFFFDEFD9),
            value: l10n.homeStreakDays(streakDays),
            label: l10n.profileStreak,
          ),
          _StatTile(
            icon: Image.asset('assets/images/ic_point.png', width: 20),
            fill: const Color(0xFFEFE3FB),
            value: formatNumber(points),
            label: l10n.profileTotalXp,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        row(
          _StatTile(
            icon: Image.asset('assets/images/ic_coin.png', width: 20),
            fill: const Color(0xFFFDF1CF),
            value: formatNumber(coins),
            label: l10n.profileCoins,
          ),
          _StatTile(
            icon: ProfileIcons.crown(size: 20),
            fill: const Color(0xFFE3F1FC),
            value: rank == null ? '—' : l10n.profileRankValue(rank),
            label: l10n.profileRank,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final Widget icon;
  final Color fill;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.fill,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: _ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
