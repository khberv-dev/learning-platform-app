import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/ui/shared/widget/app_header.dart';

class SurveyHeader extends StatelessWidget {
  final VoidCallback onBackClick;
  final int progressValue;
  final int progressMax;

  const SurveyHeader({
    super.key,
    required this.onBackClick,
    required this.progressValue,
    required this.progressMax,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      child: Row(
        children: [
          IconButton(
            onPressed: onBackClick,
            icon: SvgPicture.asset('assets/icons/arrow_left.svg'),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: LinearProgressIndicator(value: progressValue / progressMax),
          ),
          SizedBox(width: AppSpacing.lg),
          Text(
            '$progressValue/$progressMax',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
