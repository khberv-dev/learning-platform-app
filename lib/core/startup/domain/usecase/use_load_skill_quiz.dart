import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/startup/data/repository/quiz_repository.dart';
import 'package:student/core/startup/domain/entity/quiz_question_entity.dart';

final useLoadSkillQuizProvider = Provider(
  (ref) => UseLoadSkillQuiz(ref.read(quizRepositoryProvider)),
);

class UseLoadSkillQuiz {
  final QuizRepository _repository;

  const UseLoadSkillQuiz(this._repository);

  Future<List<QuizQuestionEntity>> call() async {
    final data = await _repository.loadQuiz();
    return data.map((e) => QuizQuestionEntity.parse(e)).toList();
  }
}
