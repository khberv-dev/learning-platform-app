import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/startup/domain/model/survey_query_option.dart';
import 'package:student/ui/startup/widget/survey_query_select_item.dart';

class SurveyQuerySelect extends StatelessWidget {
  final List<SurveyQueryOption> options;
  final int? current;
  final Function(int) onItemClick;

  const SurveyQuerySelect({
    super.key,
    required this.options,
    this.current,
    required this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        options.length,
        (index) => Column(
          children: [
            GestureDetector(
              onTap: () => onItemClick(index),
              child: SurveyQuerySelectItem(
                option: options[index],
                isSelected: current == index,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
