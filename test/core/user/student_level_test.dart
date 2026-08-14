import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/user/domain/entity/student_level.dart';

void main() {
  group('StudentLevel.fromScore', () {
    // The shipped quiz is 12 questions; these are the bands a student actually
    // lands in.
    const total = 12;

    StudentLevel at(int correct) =>
        StudentLevel.fromScore(correct: correct, total: total);

    test('bands the whole 0..12 range', () {
      expect(
        [for (var i = 0; i <= total; i++) at(i).code],
        [
          'A1', // 0  — at or below what guessing alone scores
          'A1', // 1
          'A1', // 2
          'A2', // 3
          'A2', // 4
          'B1', // 5
          'B1', // 6
          'B2', // 7
          'B2', // 8
          'C1', // 9
          'C1', // 10
          'C2', // 11
          'C2', // 12
        ],
      );
    });

    test('gives every level a real chance of coming up', () {
      final reached = {for (var i = 0; i <= total; i++) at(i)};
      expect(reached, StudentLevel.values.toSet());

      // No band may be a single score wide, or it becomes a rounding artefact
      // rather than a placement.
      for (final level in StudentLevel.values) {
        final scores = [
          for (var i = 0; i <= total; i++)
            if (at(i) == level) i,
        ];
        expect(
          scores.length,
          greaterThanOrEqualTo(2),
          reason: '${level.code} is only reachable by $scores',
        );
      }
    });

    test('never regresses as the score climbs', () {
      for (var i = 1; i <= total; i++) {
        expect(
          at(i).index,
          greaterThanOrEqualTo(at(i - 1).index),
          reason: 'scoring $i placed lower than ${i - 1}',
        );
      }
    });

    test('a blank sheet places at the bottom, a perfect one at the top', () {
      expect(at(0), StudentLevel.a1);
      expect(at(total), StudentLevel.c2);
    });

    test('bands on the ratio, so the quiz can change length', () {
      expect(StudentLevel.fromScore(correct: 5, total: 5), StudentLevel.c2);
      expect(StudentLevel.fromScore(correct: 12, total: 24), StudentLevel.b1);
    });

    test(
      'a quiz with no questions falls back rather than dividing by zero',
      () {
        expect(StudentLevel.fromScore(correct: 0, total: 0), StudentLevel.a1);
      },
    );
  });

  group('StudentLevel.fromCode', () {
    test('round-trips every wire value', () {
      for (final level in StudentLevel.values) {
        expect(StudentLevel.fromCode(level.code), level);
      }
    });

    test('is null for anything the API might add later', () {
      expect(StudentLevel.fromCode('D1'), isNull);
      expect(StudentLevel.fromCode(null), isNull);
      // Case matters — the API sends 'A1', never 'a1'.
      expect(StudentLevel.fromCode('a1'), isNull);
    });
  });
}
