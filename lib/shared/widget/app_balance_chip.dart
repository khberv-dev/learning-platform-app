import 'package:flutter/material.dart';
import 'package:student/utils/lib.dart';

/// A rounded chip with a currency icon and its balance — the student's points
/// or coins in the home and Mission headers.
class AppBalanceChip extends StatelessWidget {
  final String imagePath;
  final int value;
  final String semanticsLabel;
  final Color background;

  const AppBalanceChip({
    super.key,
    required this.imagePath,
    required this.value,
    required this.semanticsLabel,
    this.background = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$semanticsLabel: $value',
      child: ExcludeSemantics(
        child: Container(
          height: 32,
          constraints: const BoxConstraints(minWidth: 44),
          padding: const EdgeInsets.fromLTRB(6, 0, 9, 0),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The artwork has ~8% transparent margin, so 20 shows as ~16.
              Image.asset(imagePath, width: 20, height: 20),
              const SizedBox(width: 5),
              // Four digits ("1 240") at full size; bigger balances shrink
              // rather than push the rest of the header off a narrow screen.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 40),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatNumber(value),
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF15141A),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
