import 'package:student/core/courses/domain/entity/task_result_entity.dart';

class TaskSubmissionResponse {
  final String answer;
  final bool isCorrect;

  const TaskSubmissionResponse({required this.answer, required this.isCorrect});

  factory TaskSubmissionResponse.fromJson(Map<String, dynamic> json) =>
      TaskSubmissionResponse(
        answer: json['answer'] as String? ?? '',
        isCorrect: json['isCorrect'] as bool? ?? false,
      );

  TaskSubmissionEntity toEntity() =>
      TaskSubmissionEntity(answer: answer, isCorrect: isCorrect);
}

class TaskResultResponse {
  final String taskId;
  final String task;
  final List<String>? options;
  final String answer;
  final TaskSubmissionResponse? submission;

  const TaskResultResponse({
    required this.taskId,
    required this.task,
    required this.answer,
    this.options,
    this.submission,
  });

  factory TaskResultResponse.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = rawOptions is List
        ? rawOptions.map((e) => e as String).toList()
        : null;

    final rawSubmission = json['submission'];
    final submission = rawSubmission is Map<String, dynamic>
        ? TaskSubmissionResponse.fromJson(rawSubmission)
        : null;

    return TaskResultResponse(
      taskId: json['taskId'] as String,
      task: json['task'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      options: options,
      submission: submission,
    );
  }

  TaskResultEntity toEntity() => TaskResultEntity(
    taskId: taskId,
    question: task,
    correctAnswer: answer,
    options: options,
    submission: submission?.toEntity(),
  );
}
