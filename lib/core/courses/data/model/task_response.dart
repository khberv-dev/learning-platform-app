import 'package:student/core/courses/domain/entity/task_content_type.dart';
import 'package:student/core/courses/domain/entity/task_entity.dart';

class TaskQuestionResponse {
  final String question;
  final List<String>? options;
  final String answer;

  const TaskQuestionResponse({
    required this.question,
    required this.answer,
    this.options,
  });

  factory TaskQuestionResponse.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    return TaskQuestionResponse(
      question: json['question'] as String? ?? '',
      options: rawOptions is List
          ? rawOptions.map((e) => e.toString()).toList()
          : null,
      answer: json['answer'] as String? ?? '',
    );
  }

  TaskQuestionEntity toEntity() =>
      TaskQuestionEntity(question: question, options: options, answer: answer);
}

class TaskResponse {
  final String id;
  final String? name;
  final List<TaskQuestionResponse> questions;
  final String? file;
  final TaskContentType? contentType;

  const TaskResponse({
    required this.id,
    required this.questions,
    this.name,
    this.file,
    this.contentType,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? [];
    return TaskResponse(
      id: json['id'].toString(),
      name: json['name'] as String?,
      questions: rawQuestions
          .map((e) => TaskQuestionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      file: json['file'] as String?,
      contentType: TaskContentType.fromJson(json['contentType'] as String?),
    );
  }

  TaskEntity toEntity() => TaskEntity(
    id: id,
    name: name,
    questions: questions.map((q) => q.toEntity()).toList(),
    file: file,
    contentType: contentType,
  );
}
