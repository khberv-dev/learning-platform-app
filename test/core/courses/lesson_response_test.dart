import 'package:flutter_test/flutter_test.dart';
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
}
