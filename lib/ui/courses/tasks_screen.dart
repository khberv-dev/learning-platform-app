import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/domain/entity/task_entity.dart';
import 'package:student/core/courses/domain/usecase/use_submit_tasks.dart';
import 'package:student/core/courses/presentation/tasks_controller.dart';

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
  final Map<String, String> _answers = {};
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  TasksParams get _params => (
    courseId: widget.courseId,
    unitId: widget.unitId,
    lessonId: widget.lessonId,
  );

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  bool _canAdvance(TaskEntity task) {
    if (task.isMultipleChoice) return _answers.containsKey(task.id);
    return _textController.text.trim().isNotEmpty;
  }

  void _selectOption(TaskEntity task, String option) {
    setState(() => _answers[task.id] = option);
  }

  void _next(TaskEntity task) {
    if (!task.isMultipleChoice) {
      _answers[task.id] = _textController.text.trim();
      _textController.clear();
    }
    setState(() => _currentIndex++);
  }

  Future<void> _submit(TaskEntity task) async {
    if (!task.isMultipleChoice) {
      _answers[task.id] = _textController.text.trim();
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(useSubmitTasksProvider).call(_answers);
      ref.invalidate(lessonTaskResultsProvider(widget.lessonId));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
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
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
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
                data: (tasks) {
                  if (tasks.isEmpty) return const _EmptyState();
                  final idx = _currentIndex.clamp(0, tasks.length - 1);
                  final task = tasks[idx];
                  final isLast = idx == tasks.length - 1;
                  return Column(
                    children: [
                      _QueueProgress(
                        current: idx + 1,
                        total: tasks.length,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _TaskCard(
                            index: idx,
                            task: task,
                            selectedAnswer: _answers[task.id],
                            textController: _textController,
                            onOptionTap: (opt) => _selectOption(task, opt),
                          ),
                        ),
                      ),
                      _BottomBar(
                        isLast: isLast,
                        isSubmitting: _isSubmitting,
                        canAdvance: _canAdvance(task),
                        onNext: () => _next(task),
                        onSubmit: () => _submit(task),
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
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
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
  final int index;
  final TaskEntity task;
  final String? selectedAnswer;
  final TextEditingController textController;
  final void Function(String) onOptionTap;

  const _TaskCard({
    required this.index,
    required this.task,
    required this.selectedAnswer,
    required this.textController,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            task.question,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          if (task.isMultipleChoice)
            ...task.options!.map(
              (opt) => _OptionTile(
                label: opt,
                isSelected: selectedAnswer == opt,
                onTap: () => onOptionTap(opt),
              ),
            )
          else
            _OpenAnswerField(controller: textController),
        ],
      ),
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
          color: isSelected
              ? const Color(0xFFF0FDF4)
              : const Color(0xFFF9FAFB),
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

class _OpenAnswerField extends StatefulWidget {
  final TextEditingController controller;

  const _OpenAnswerField({required this.controller});

  @override
  State<_OpenAnswerField> createState() => _OpenAnswerFieldState();
}

class _OpenAnswerFieldState extends State<_OpenAnswerField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      autofocus: true,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 14,
      ),
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
      minLines: 3,
      maxLines: 5,
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool isLast;
  final bool isSubmitting;
  final bool canAdvance;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.isLast,
    required this.isSubmitting,
    required this.canAdvance,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
      ),
      child: SizedBox(
        width: double.infinity,
        child: isLast
            ? FilledButton(
                onPressed: (canAdvance && !isSubmitting) ? onSubmit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF18C96A),
                  disabledBackgroundColor: const Color(0xFFD1FAE5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              )
            : FilledButton.icon(
                onPressed: canAdvance ? onNext : null,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text(
                  'Next',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF18C96A),
                  disabledBackgroundColor: const Color(0xFFD1FAE5),
                  foregroundColor: Colors.white,
                  iconColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
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
