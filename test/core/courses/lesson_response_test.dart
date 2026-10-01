import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/data/model/lesson_response.dart';

void main() {
  test('maps the lesson lock state from the API', () {
    final lesson = LessonResponse.fromJson({
      'id': 'lesson-1',
      'title': 'Locked lesson',
      'isLocked': true,
    }).toEntity();

    expect(lesson.isLocked, isTrue);
  });

  test('lessons remain unlocked when the API omits isLocked', () {
    final lesson = LessonResponse.fromJson({
      'id': 'lesson-1',
      'title': 'First lesson',
    }).toEntity();

    expect(lesson.isLocked, isFalse);
  });

  test('reads the lesson length in seconds, when sent', () {
    final timed = LessonResponse.fromJson({
      'id': 'l1',
      'title': 'Intro',
      'duration': 130,
    }).toEntity();
    final untimed = LessonResponse.fromJson({
      'id': 'l2',
      'title': 'Vowels',
    }).toEntity();

    expect(timed.duration, const Duration(minutes: 2, seconds: 10));
    expect(untimed.duration, isNull);
  });

  test('reads progress, nested like the detail or flat', () {
    LessonEntity parse(Map<String, dynamic> extra) => LessonResponse.fromJson({
      'id': 'l1',
      'title': 'Intro',
      ...extra,
    }).toEntity();

    expect(
      parse({
        'taskProgression': {'progressPercent': 85},
      }).progressPercent,
      85,
    );
    expect(parse({'progressPercent': 40}).progressPercent, 40);
    expect(parse({}).progressPercent, isNull);
    expect(parse({'progressPercent': 80}).isPassed, isTrue);
    expect(parse({'progressPercent': 79}).isPassed, isFalse);
    expect(parse({}).isPassed, isFalse);
  });
}
