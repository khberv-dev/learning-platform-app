/// One question's outcome from a task submission.
///
/// [answer] (the correct one) is only ever sent back when [isCorrect] is
/// true — the API withholds it on a wrong answer so the student can't just
/// read it off the response and resubmit.
class TaskSubmissionQuestionResultEntity {
  final String question;
  final List<String>? options;
  final String? studentAnswer;
  final bool isCorrect;
  final String? answer;

  const TaskSubmissionQuestionResultEntity({
    required this.question,
    required this.isCorrect,
    this.options,
    this.studentAnswer,
    this.answer,
  });
}

/// One task's outcome from `POST student/task-submissions`. [isCorrect] is
/// the task-level pass/fail (>=80% of its questions correct), which can be
/// true even when a question inside it was missed.
class TaskSubmissionResultEntity {
  final String taskId;
  final List<TaskSubmissionQuestionResultEntity> questions;
  final bool isCorrect;
  final int coinsEarned;

  const TaskSubmissionResultEntity({
    required this.taskId,
    required this.questions,
    required this.isCorrect,
    required this.coinsEarned,
  });
}
