import 'package:student/core/courses/domain/entity/task_entity.dart';

class TaskResponse {
  final String id;
  final String task;
  final List<String>? options;
  final String answer;

  const TaskResponse({
    required this.id,
    required this.task,
    required this.answer,
    this.options,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) => TaskResponse(
    id: json['id'] as String,
    task: json['task'] as String,
    options: (json['options'] as List<dynamic>?)?.cast<String>(),
    answer: json['answer'] as String,
  );

  TaskEntity toEntity() =>
      TaskEntity(id: id, question: task, options: options, answer: answer);
}
