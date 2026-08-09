import 'package:student/core/courses/data/model/task_response.dart';
import 'package:student/core/courses/domain/entity/task_content_type.dart';
import 'package:student/core/courses/domain/entity/task_result_entity.dart';

class TaskSubmissionResponse {
  final List<String> answers;
  final bool isCorrect;
  final DateTime? submittedAt;

  const TaskSubmissionResponse({
    required this.answers,
    required this.isCorrect,
    this.submittedAt,
  });

  factory TaskSubmissionResponse.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    return TaskSubmissionResponse(
      answers: rawAnswers is List
          ? rawAnswers.map((e) => e.toString()).toList()
          : const [],
      isCorrect: json['isCorrect'] as bool? ?? false,
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? ''),
    );
  }

  TaskSubmissionEntity toEntity() => TaskSubmissionEntity(
    answers: answers,
    isCorrect: isCorrect,
    submittedAt: submittedAt,
  );
}

class TaskResultResponse {
  final String taskId;
  final String? name;
  final List<TaskQuestionResponse> questions;
  final String? file;
  final TaskContentType? contentType;
  final TaskSubmissionResponse? submission;

  const TaskResultResponse({
    required this.taskId,
    required this.questions,
    this.name,
    this.file,
    this.contentType,
    this.submission,
  });

  factory TaskResultResponse.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? [];
    final rawSubmission = json['submission'];

    return TaskResultResponse(
      taskId: json['taskId'].toString(),
      name: json['name'] as String?,
      questions: rawQuestions
          .map((e) => TaskQuestionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      file: json['file'] as String?,
      contentType: TaskContentType.fromJson(json['contentType'] as String?),
      submission: rawSubmission is Map<String, dynamic>
          ? TaskSubmissionResponse.fromJson(rawSubmission)
          : null,
    );
  }

  TaskResultEntity toEntity() => TaskResultEntity(
    taskId: taskId,
    name: name,
    questions: questions.map((q) => q.toEntity()).toList(),
    file: file,
    contentType: contentType,
    submission: submission?.toEntity(),
  );
}
