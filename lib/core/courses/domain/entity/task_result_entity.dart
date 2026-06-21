class TaskSubmissionEntity {
  final String answer;
  final bool isCorrect;

  const TaskSubmissionEntity({required this.answer, required this.isCorrect});
}

class TaskResultEntity {
  final String taskId;
  final String question;
  final List<String>? options;
  final String correctAnswer;
  final TaskSubmissionEntity? submission;

  const TaskResultEntity({
    required this.taskId,
    required this.question,
    required this.correctAnswer,
    this.options,
    this.submission,
  });

  bool get isAnswered => submission != null;

  bool get isMultipleChoice => options != null && options!.isNotEmpty;
}
