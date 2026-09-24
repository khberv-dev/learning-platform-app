import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/courses/domain/entity/task_entity.dart';
import 'package:student/core/courses/domain/entity/task_submission_result_entity.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';

/// What [TaskResultsScreen] needs, bundled for `state.extra`. [tasks] is the
/// list already fetched for the attempt screen — the submission response
/// itself carries no task name, only its id.
typedef TaskResultsArgs = ({
  List<TaskSubmissionResultEntity> results,
  List<TaskEntity> tasks,
});

/// Shows what came back from `POST student/task-submissions`: which answers
/// were right or wrong, question by question. A wrong answer's correct one
/// is withheld by the API itself (only ever sent back once you get it
/// right), so this never shows one for a question you missed.
class TaskResultsScreen extends StatelessWidget {
  static const path = '/task-results';

  final List<TaskSubmissionResultEntity> results;
  final List<TaskEntity> tasks;

  const TaskResultsScreen({
    super.key,
    required this.results,
    required this.tasks,
  });

  TaskEntity? _taskFor(String taskId) {
    for (final task in tasks) {
      if (task.id == taskId) return task;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allQuestions = results.expand((r) => r.questions).toList();
    final correctCount = allQuestions.where((q) => q.isCorrect).length;
    final coinsEarned = results.fold(0, (sum, r) => sum + r.coinsEarned);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.taskResultsTitle,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _SummaryCard(
              correct: correctCount,
              total: allQuestions.length,
              coinsEarned: coinsEarned,
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                itemCount: results.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final result = results[i];
                  final task = _taskFor(result.taskId);
                  return _TaskResultCard(
                    title: task?.name?.isNotEmpty == true
                        ? task!.name!
                        : l10n.taskFallbackName,
                    result: result,
                  );
                },
              ),
            ),
            AppBottomActionBar(
              children: [
                AppButton.filled(
                  label: l10n.taskResultsDone,
                  // Pops both this screen and the attempt screen beneath it,
                  // back to the lesson — there's nothing left to do here once
                  // results are in.
                  onTap: () {
                    context.pop();
                    context.pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int correct;
  final int total;
  final int coinsEarned;

  const _SummaryCard({
    required this.correct,
    required this.total,
    required this.coinsEarned,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allCorrect = total > 0 && correct == total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: allCorrect
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFFFF7ED),
                shape: BoxShape.circle,
              ),
              child: Icon(
                allCorrect ? Icons.celebration_rounded : Icons.task_alt_rounded,
                color: allCorrect
                    ? const Color(0xFF18C96A)
                    : const Color(0xFFF59E0B),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.taskResultsSummary(correct, total),
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (coinsEarned > 0) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/coin_chip.png',
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.taskResultsCoinsEarned(coinsEarned),
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskResultCard extends StatelessWidget {
  final String title;
  final TaskSubmissionResultEntity result;

  const _TaskResultCard({required this.title, required this.result});

  @override
  Widget build(BuildContext context) {
    final showNumbers = result.questions.length > 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < result.questions.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF3F4F6),
                ),
              ),
            _QuestionResultRow(
              result: result.questions[i],
              number: showNumbers ? i + 1 : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestionResultRow extends StatelessWidget {
  final TaskSubmissionQuestionResultEntity result;
  final int? number;

  const _QuestionResultRow({required this.result, this.number});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = result.isCorrect
        ? const Color(0xFF18C96A)
        : const Color(0xFFEF4444);
    final answer = result.studentAnswer;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(
            result.isCorrect ? Icons.check_rounded : Icons.close_rounded,
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number != null
                    ? '$number. ${result.question}'
                    : result.question,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                result.isCorrect
                    ? l10n.taskResultsCorrect
                    : l10n.taskResultsIncorrect,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                answer?.isNotEmpty == true
                    ? l10n.taskResultsYourAnswer(answer!)
                    : l10n.taskResultsNoAnswer,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
