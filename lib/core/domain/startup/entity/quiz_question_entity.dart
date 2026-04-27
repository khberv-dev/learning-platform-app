class QuizQuestionEntity {
  final String question;
  final List<String> options;
  final String correct;

  QuizQuestionEntity({
    required this.question,
    required this.options,
    required this.correct,
  });

  factory QuizQuestionEntity.parse(Map<String, dynamic> data) =>
      QuizQuestionEntity(
        question: data['question'],
        options: List<String>.from(data['options']),
        correct: data['correct'],
      );
}
