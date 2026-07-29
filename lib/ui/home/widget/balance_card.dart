import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/shared/widget/app_panel.dart';
import 'package:student/utils/lib.dart';

/// Navy from the chip artwork, so the wallet badge sits in the same palette
/// as the score/coin/leaderboard icons above it.
const _iconInk = Color(0xff1b1b8f);

class BalanceCard extends StatelessWidget {
  final int balance;
  final VoidCallback? onTap;

  const BalanceCard({super.key, required this.balance, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: _iconInk, width: 2.5),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: _iconInk,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Balances reach seven figures, so scale rather than wrap.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${formatNumber(balance)} UZS',
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Balance',
                  style: TextStyle(
                    color: Color(0xff8fa3b0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
