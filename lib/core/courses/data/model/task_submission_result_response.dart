import 'package:student/core/courses/domain/entity/task_submission_result_entity.dart';

class TaskSubmissionQuestionResultResponse {
  final String question;
  final List<String>? options;
  final String? studentAnswer;
  final bool isCorrect;
  final String? answer;

  const TaskSubmissionQuestionResultResponse({
    required this.question,
    required this.isCorrect,
    this.options,
    this.studentAnswer,
    this.answer,
  });

  factory TaskSubmissionQuestionResultResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawOptions = json['options'];
    return TaskSubmissionQuestionResultResponse(
      question: json['question'] as String? ?? '',
      options: rawOptions is List
          ? rawOptions.map((e) => e.toString()).toList()
          : null,
      studentAnswer: json['studentAnswer'] as String?,
      isCorrect: json['isCorrect'] as bool? ?? false,
      answer: json['answer'] as String?,
    );
  }

  TaskSubmissionQuestionResultEntity toEntity() =>
      TaskSubmissionQuestionResultEntity(
        question: question,
        options: options,
        studentAnswer: studentAnswer,
        isCorrect: isCorrect,
        answer: answer,
      );
}

class TaskSubmissionResultResponse {
  final String taskId;
  final List<TaskSubmissionQuestionResultResponse> questions;
  final bool isCorrect;
  final int coinsEarned;

  const TaskSubmissionResultResponse({
    required this.taskId,
    required this.questions,
    required this.isCorrect,
    required this.coinsEarned,
  });

  factory TaskSubmissionResultResponse.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? [];
    return TaskSubmissionResultResponse(
      taskId: json['taskId'].toString(),
      questions: rawQuestions
          .map(
            (e) => TaskSubmissionQuestionResultResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      isCorrect: json['isCorrect'] as bool? ?? false,
      coinsEarned: (json['coinsEarned'] as num?)?.toInt() ?? 0,
    );
  }

  TaskSubmissionResultEntity toEntity() => TaskSubmissionResultEntity(
    taskId: taskId,
    questions: questions.map((q) => q.toEntity()).toList(),
    isCorrect: isCorrect,
    coinsEarned: coinsEarned,
  );
}
