import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final quizRepositoryProvider = Provider((ref) => QuizRepository());

class QuizRepository {
  Future<List<Map<String, dynamic>>> loadQuiz() async {
    final rawData = await rootBundle.loadString('assets/skill_quiz.json');
    final json = jsonDecode(rawData) as List<dynamic>;

    return json.map((element) => element as Map<String, dynamic>).toList();
  }
}
