import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/domain/startup/entity/quiz_question_entity.dart';
import 'package:student/core/domain/startup/usecase/load_skill_quiz.dart';

final skillQuestionsController = NotifierProvider(_SkillQuestionsNotifier.new);

class _SkillQuestionsNotifier extends Notifier<List<QuizQuestionEntity>> {
  @override
  List<QuizQuestionEntity> build() {
    load();

    return [];
  }

  Future<void> load() async {
    final quizData = await ref.read(loadSkillQuizProvider).call();

    state = quizData;
  }
}
