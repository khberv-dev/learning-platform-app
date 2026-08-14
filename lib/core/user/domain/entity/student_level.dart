/// CEFR band a student sits in, matching the API's `StudentLevel` enum.
///
/// The API takes this as an optional field on sign-up and falls back to [a1]
/// when it isn't sent — a student who skips the placement quiz starts there.
enum StudentLevel {
  a1('A1'),
  a2('A2'),
  b1('B1'),
  b2('B2'),
  c1('C1'),
  c2('C2');

  /// Wire value, e.g. `A1`. The name can't be used directly because Dart enum
  /// names are lower-case and the API's are not.
  final String code;

  const StudentLevel(this.code);

  static StudentLevel? fromCode(String? raw) {
    for (final level in values) {
      if (level.code == raw) return level;
    }
    return null;
  }

  /// Places a student from how much of the placement quiz they got right.
  ///
  /// Banded on the ratio rather than a raw count, so the quiz can grow or
  /// shrink without silently re-grading everyone.
  ///
  /// [a1] deliberately runs all the way to 25%: the questions are four-option
  /// multiple choice, so pure guessing already scores about that, and a score
  /// at chance level says nothing except "beginner".
  ///
  /// The thresholds above it are set just under the ratios they mean to catch
  /// — 0.41 rather than 0.42 for 5-of-12 — because the obvious round numbers
  /// fall on the wrong side of the division. Left rounder, the bands come out
  /// badly lopsided: at 12 questions an earlier cut made [b2] reachable by a
  /// single score out of thirteen.
  static StudentLevel fromScore({required int correct, required int total}) {
    if (total <= 0) return StudentLevel.a1;

    final ratio = correct / total;
    return switch (ratio) {
      >= 0.91 => StudentLevel.c2,
      >= 0.75 => StudentLevel.c1,
      >= 0.58 => StudentLevel.b2,
      >= 0.41 => StudentLevel.b1,
      >= 0.25 => StudentLevel.a2,
      _ => StudentLevel.a1,
    };
  }
}
