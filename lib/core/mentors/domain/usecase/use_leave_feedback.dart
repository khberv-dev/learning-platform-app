import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/mentors/data/repository/mentors_repository.dart';
import 'package:student/core/mentors/domain/repository/i_mentors_repository.dart';

final useLeaveFeedbackProvider = Provider(
  (ref) => UseLeaveFeedback(ref.read(mentorsRepositoryProvider)),
);

class UseLeaveFeedback {
  final IMentorsRepository _repository;

  const UseLeaveFeedback(this._repository);

  Future<void> call({
    required String mentorId,
    required String text,
    required int rate,
  }) => _repository.leaveFeedback(id: mentorId, text: text, rate: rate);
}
