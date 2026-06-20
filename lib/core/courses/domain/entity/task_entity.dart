class TaskEntity {
  final String id;
  final String question;
  final List<String>? options;
  final String answer;

  const TaskEntity({
    required this.id,
    required this.question,
    required this.answer,
    this.options,
  });

  bool get isMultipleChoice => options != null && options!.isNotEmpty;
}
