enum AssessmentRole { user, assistant }

class ConversationMessageEntity {
  final String id;
  final AssessmentRole role;
  final String text;
  final String? audioPath;
  final DateTime createdAt;

  const ConversationMessageEntity({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.audioPath,
  });
}
