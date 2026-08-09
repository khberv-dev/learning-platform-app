import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/domain/entity/task_entity.dart';
import 'package:student/core/courses/domain/usecase/use_submit_tasks.dart';
import 'package:student/core/courses/presentation/tasks_controller.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/ui/courses/widget/task_content_view.dart';
import 'package:student/utils/messenger.dart';

/// One task per page. A task groups several questions under an optional piece
/// of content (audio to listen to, a picture, or a text passage), and the API
/// takes one answer string per question, in question order.
class TasksScreen extends ConsumerStatefulWidget {
  static const path = '/tasks';

  final String courseId;
  final String unitId;
  final String lessonId;
  final String lessonTitle;

  const TasksScreen({
    super.key,
    required this.courseId,
    required this.unitId,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  int _currentIndex = 0;

  /// taskId → one answer per question, in order. Grown to the task's question
  /// count the first time any of its questions is answered.
  final Map<String, List<String>> _answers = {};

  /// `taskId:questionIndex` → controller, so drafts survive stepping back and
  /// forth between tasks.
  final Map<String, TextEditingController> _controllers = {};

  bool _isSubmitting = false;

  TasksParams get _params => (
    courseId: widget.courseId,
    unitId: widget.unitId,
    lessonId: widget.lessonId,
  );

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> _answersFor(TaskEntity task) => _answers.putIfAbsent(
    task.id,
    () => List<String>.filled(task.questions.length, '', growable: false),
  );

  String _answerAt(TaskEntity task, int questionIndex) =>
      _answersFor(task)[questionIndex];

  void _setAnswer(TaskEntity task, int questionIndex, String value) {
    setState(() => _answersFor(task)[questionIndex] = value);
  }

  TextEditingController _controllerFor(TaskEntity task, int questionIndex) {
    return _controllers.putIfAbsent('${task.id}:$questionIndex', () {
      final controller = TextEditingController(
        text: _answerAt(task, questionIndex),
      );
      controller.addListener(
        () => _setAnswer(task, questionIndex, controller.text),
      );
      return controller;
    });
  }

  bool _isComplete(TaskEntity task) =>
      _answersFor(task).every((a) => a.trim().isNotEmpty);

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final payload = _answers.map(
        (taskId, answers) =>
            MapEntry(taskId, answers.map((a) => a.trim()).toList()),
      );
      await ref.read(useSubmitTasksProvider).call(payload);
      ref.invalidate(lessonTaskResultsProvider(widget.lessonId));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        showErrorMessage(context, apiErrorMessage(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksControllerProvider(_params));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(lessonTitle: widget.lessonTitle),
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      e.toString(),
                      style: const TextStyle(color: Color(0xFF6B7280)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (allTasks) {
                  // A task with no questions is nothing to answer — content
                  // alone belongs on the lesson, not in the solving queue.
                  final tasks = allTasks
                      .where((t) => t.questions.isNotEmpty)
                      .toList();
                  if (tasks.isEmpty) return const _EmptyState();

                  final idx = _currentIndex.clamp(0, tasks.length - 1);
                  final task = tasks[idx];
                  final isLast = idx == tasks.length - 1;

                  return Column(
                    children: [
                      _QueueProgress(current: idx + 1, total: tasks.length),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _TaskCard(
                            task: task,
                            answerAt: (qi) => _answerAt(task, qi),
                            controllerFor: (qi) => _controllerFor(task, qi),
                            onOptionTap: (qi, option) =>
                                _setAnswer(task, qi, option),
                          ),
                        ),
                      ),
                      _BottomBar(
                        isFirst: idx == 0,
                        isLast: isLast,
                        isSubmitting: _isSubmitting,
                        canAdvance: _isComplete(task),
                        onBack: () => setState(() => _currentIndex = idx - 1),
                        onNext: () => setState(() => _currentIndex = idx + 1),
                        onSubmit: _submit,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String lessonTitle;

  const _Header({required this.lessonTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: Navigator.of(context).pop,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 18,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  lessonTitle,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress ──────────────────────────────────────────────────────────────────

class _QueueProgress extends StatelessWidget {
  final int current;
  final int total;

  const _QueueProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Task $current of $total',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF18C96A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF18C96A)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task card ─────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskEntity task;
  final String Function(int questionIndex) answerAt;
  final TextEditingController Function(int questionIndex) controllerFor;
  final void Function(int questionIndex, String option) onOptionTap;

  const _TaskCard({
    required this.task,
    required this.answerAt,
    required this.controllerFor,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    final showNumbers = task.questions.length > 1;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.name != null && task.name!.isNotEmpty) ...[
            Text(
              task.name!,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (task.hasContent) ...[
            TaskContentView(
              file: task.file!,
              contentType: task.contentType!,
              // The audio has to be re-fetched per task, and reusing one key
              // across tasks would keep the previous clip loaded.
              key: ValueKey(task.id),
            ),
            const SizedBox(height: 20),
          ],
          for (var i = 0; i < task.questions.length; i++) ...[
            if (i > 0) const _QuestionDivider(),
            _QuestionBlock(
              question: task.questions[i],
              number: showNumbers ? i + 1 : null,
              selectedAnswer: answerAt(i),
              controller: controllerFor(i),
              onOptionTap: (option) => onOptionTap(i, option),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestionDivider extends StatelessWidget {
  const _QuestionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
    );
  }
}

// ── Question ──────────────────────────────────────────────────────────────────

class _QuestionBlock extends StatelessWidget {
  final TaskQuestionEntity question;

  /// 1-based label, shown only when the task holds more than one question.
  final int? number;

  final String selectedAnswer;
  final TextEditingController controller;
  final void Function(String option) onOptionTap;

  const _QuestionBlock({
    required this.question,
    required this.number,
    required this.selectedAnswer,
    required this.controller,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (number != null) ...[
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 2),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Color(0xFF18C96A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                question.question,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (question.isMultipleChoice)
          ...question.options!.map(
            (opt) => _OptionTile(
              label: opt,
              isSelected: selectedAnswer == opt,
              onTap: () => onOptionTap(opt),
            ),
          )
        else
          _OpenAnswerField(controller: controller),
      ],
    );
  }
}

// ── Option tile ───────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF18C96A)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF18C96A)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF18C96A)
                      : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF15803D)
                      : const Color(0xFF374151),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Open answer field ─────────────────────────────────────────────────────────

class _OpenAnswerField extends StatelessWidget {
  final TextEditingController controller;

  const _OpenAnswerField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Type your answer…',
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF18C96A), width: 2),
        ),
      ),
      minLines: 2,
      maxLines: 5,
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isSubmitting;
  final bool canAdvance;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.isFirst,
    required this.isLast,
    required this.isSubmitting,
    required this.canAdvance,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(color: Color(0xFFF5F7FA)),
      child: Row(
        children: [
          if (!isFirst) ...[
            Expanded(
              child: AppButton.white(
                label: 'Back',
                fontSize: 15,
                onTap: isSubmitting ? null : onBack,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: isLast
                ? AppButton.filled(
                    label: 'Submit',
                    fontSize: 15,
                    isLoading: isSubmitting,
                    onTap: canAdvance ? onSubmit : null,
                  )
                : AppButton.filled(
                    label: 'Next',
                    icon: const Icon(Icons.arrow_forward_rounded),
                    fontSize: 15,
                    onTap: canAdvance ? onNext : null,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: Color(0xFF18C96A),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Tasks Yet',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tasks for this lesson will appear here.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
