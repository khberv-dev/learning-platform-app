import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/user/domain/entity/student_level.dart';

/// Level the placement quiz placed the student at, held between finishing the
/// quiz and completing sign-up a couple of screens later.
///
/// Null until the quiz is finished — someone who closes it early, or who lands
/// on the register screen another way, registers without a level and the API
/// applies its own default.
final skillQuizResultProvider =
    NotifierProvider<SkillQuizResultNotifier, StudentLevel?>(
      SkillQuizResultNotifier.new,
    );

class SkillQuizResultNotifier extends Notifier<StudentLevel?> {
  @override
  StudentLevel? build() => null;

  void setLevel(StudentLevel level) => state = level;

  void clear() => state = null;
}
