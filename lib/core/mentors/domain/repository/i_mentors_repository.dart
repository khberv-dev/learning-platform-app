import 'package:student/core/mentors/domain/entity/mentor_entity.dart';

abstract class IMentorsRepository {
  Future<List<MentorEntity>> getMentors();

  Future<MentorEntity> getMentor(String id);

  /// Leaves feedback for mentor [id]. [rate] is 0-5.
  Future<void> leaveFeedback({
    required String id,
    required String text,
    required int rate,
  });
}
