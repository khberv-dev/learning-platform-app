import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/ui/startup/widget/quiz_option_select_item.dart';

const _optionLabels = 'ABCDE';

class QuizOptionSelect extends StatelessWidget {
  final List<String> options;
  final int? current;
  final Function(int) onItemClick;

  const QuizOptionSelect({
    super.key,
    required this.options,
    required this.current,
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
              child: QuizOptionSelectItem(
                label: _optionLabels[index],
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
