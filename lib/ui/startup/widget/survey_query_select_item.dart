import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/domain/startup/model/survey_query_option.dart';

class SurveyQuerySelectItem extends StatelessWidget {
  final SurveyQueryOption option;
  final bool isSelected;

  const SurveyQuerySelectItem({
    super.key,
    required this.option,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? Theme.of(context).colorScheme.primary.withAlpha(20)
        : Colors.transparent;

    final borderColor = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(50);

    final iconColor = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(width: 1.7, color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            option.iconPath,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            option.text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
