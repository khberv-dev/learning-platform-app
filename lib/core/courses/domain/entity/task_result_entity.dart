import 'package:student/core/courses/domain/entity/task_content_type.dart';
import 'package:student/core/courses/domain/entity/task_entity.dart';

class TaskSubmissionEntity {
  /// One answer per question of the task, in question order.
  final List<String> answers;

  /// The API marks a whole task correct only when every question matches.
  final bool isCorrect;

  final DateTime? submittedAt;

  const TaskSubmissionEntity({
    required this.answers,
    required this.isCorrect,
    this.submittedAt,
  });

  String? answerAt(int index) => index < answers.length ? answers[index] : null;
}

class TaskResultEntity {
  final String taskId;
  final String? name;
  final List<TaskQuestionEntity> questions;
  final String? file;
  final TaskContentType? contentType;
  final TaskSubmissionEntity? submission;

  const TaskResultEntity({
    required this.taskId,
    required this.questions,
    this.name,
    this.file,
    this.contentType,
    this.submission,
  });

  bool get isAnswered => submission != null;
}
