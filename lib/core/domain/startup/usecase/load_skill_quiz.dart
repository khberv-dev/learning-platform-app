import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/data/startup/repository/quiz_repository.dart';
import 'package:student/core/domain/startup/entity/quiz_question_entity.dart';

final loadSkillQuizProvider = Provider(
  (ref) => LoadSkillQuiz(ref.read(quizRepositoryProvider)),
);

class LoadSkillQuiz {
  final QuizRepository _repository;

  LoadSkillQuiz(this._repository);

  Future<List<QuizQuestionEntity>> call() async {
    final data = await _repository.loadQuiz();

    return data.map((element) => QuizQuestionEntity.parse(element)).toList();
  }
}
