import 'package:student/core/courses/domain/entity/task_content_type.dart';

/// One question inside a task. [options] is null for open answers.
class TaskQuestionEntity {
  final String question;
  final List<String>? options;
  final String answer;

  const TaskQuestionEntity({
    required this.question,
    required this.answer,
    this.options,
  });

  bool get isMultipleChoice => options != null && options!.isNotEmpty;
}

/// A task groups several questions under one optional piece of content — an
/// audio clip to listen to, a picture to describe, or a text passage to read.
class TaskEntity {
  final String id;
  final String? name;
  final List<TaskQuestionEntity> questions;

  /// A CDN path when [contentType] is audio/picture, the passage itself when
  /// it is text. Null when the task is questions-only.
  final String? file;
  final TaskContentType? contentType;

  const TaskEntity({
    required this.id,
    required this.questions,
    this.name,
    this.file,
    this.contentType,
  });

  bool get hasContent =>
      contentType != null && file != null && file!.isNotEmpty;
}
