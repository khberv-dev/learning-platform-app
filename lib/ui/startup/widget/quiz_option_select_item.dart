import 'package:flutter/material.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';

class QuizOptionSelectItem extends StatelessWidget {
  final String label;
  final String option;
  final bool isSelected;

  const QuizOptionSelectItem({
    super.key,
    required this.label,
    required this.option,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? Theme.of(context).colorScheme.primary.withAlpha(20)
        : Colors.transparent;

    final labelBgColor = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withAlpha(20);

    final labelColor = isSelected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    final borderColor = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(50);

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(width: 1.7, color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: labelBgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              option,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
