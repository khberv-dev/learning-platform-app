import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';

const _ink = Color(0xFF15141A);
const _muted = Color(0xFF717384);

/// The pale green glow behind the mascot, fading out towards the text.
const _glow = Color(0xFFDDF4C6);

const _cardHeight = 102.0;
const _mascotHeight = 116.0;
const _mascotWidth = 136.0;

/// How far the mascot rises above the card's top edge. Reserved as padding
/// so it never overlaps whatever sits above the card.
const _mascotOverhang = 18.0;

/// Home's streak card: a title and a line of encouragement on the left, and
/// the cloud mascot on the right, peeking over the top edge. Its artwork
/// changes with the streak — unlit at 0, a campfire from day 1, and
/// milestone badges at 20 and 30.
class StreakCard extends StatelessWidget {
  /// Consecutive days practised.
  final int days;

  const StreakCard({super.key, required this.days});

  static String mascotFor(int days) => switch (days) {
    <= 0 => 'assets/images/mascot_streak_0.png',
    < 20 => 'assets/images/mascot_streak_1.png',
    < 30 => 'assets/images/mascot_streak_20.png',
    _ => 'assets/images/mascot_streak_30.png',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final started = days > 0;

    return Padding(
      padding: const EdgeInsets.only(top: _mascotOverhang),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: _cardHeight),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            // A gradient replaces a decoration's colour, so the glow is its
            // own layer over the white.
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomRight,
                  radius: 1.1,
                  colors: [_glow, Color(0x00FFFFFF)],
                  stops: [0, 0.55],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  _mascotWidth - AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        started
                            ? l10n.homeStreakDays(days)
                            : l10n.homeStreakStartTitle,
                        maxLines: 1,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      started
                          ? l10n.homeDontForgetMe
                          : l10n.homeStreakStartSubtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Pinned from the top, so the overhang holds even when longer text
          // (Russian, a large font scale) makes the card taller.
          Positioned(
            right: 4,
            top: -_mascotOverhang,
            child: Image.asset(
              mascotFor(days),
              key: const ValueKey('streak-mascot'),
              width: _mascotWidth,
              height: _mascotHeight,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    );
  }
}
