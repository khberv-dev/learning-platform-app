import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/courses/data/model/course_detail_response.dart';
import 'package:student/core/courses/data/model/unit_response.dart';

void main() {
  group('CourseDetailResponse', () {
    test('reads the course and its authors', () {
      final course = CourseDetailResponse.fromJson({
        'id': 'da1833db',
        'title': 'General English',
        'description': 'A beginner-friendly English course.',
        'image': 'https://storage.example/course.jpg',
        'totalProgress': 0,
        'authors': [
          {
            'id': '69645d53',
            'firstName': 'Dajjar',
            'lastName': 'Mahhal',
            'gender': 'male',
            'avatar': 'https://storage.example/avatar.jpg',
            'description': "zo'r o'qituvchida shuu",
            'createdAt': '2026-09-30T06:48:35.537Z',
            'updatedAt': '2026-09-30T06:48:35.537Z',
          },
        ],
      }).toEntity();

      expect(course.title, 'General English');
      expect(course.authors, hasLength(1));
      final author = course.authors.single;
      expect(author.id, '69645d53');
      expect(author.fullName, 'Dajjar Mahhal');
      expect(author.avatar, 'https://storage.example/avatar.jpg');
      expect(author.description, "zo'r o'qituvchida shuu");
    });

    test('a course with no authors field has none', () {
      final course = CourseDetailResponse.fromJson({
        'id': 'c1',
        'title': 'Course',
      }).toEntity();

      expect(course.authors, isEmpty);
    });

    test("an author without a last name is just the first name", () {
      final course = CourseDetailResponse.fromJson({
        'id': 'c1',
        'title': 'Course',
        'authors': [
          {'id': 'a1', 'firstName': 'Dilnoza', 'lastName': null},
        ],
      }).toEntity();

      expect(course.authors.single.fullName, 'Dilnoza');
    });
  });

  group('UnitResponse', () {
    test('reads isLocked, defaulting to open', () {
      expect(
        UnitResponse.fromJson({
          'id': 'u1',
          'title': 'Unit',
          'lessonsCount': 3,
          'isLocked': true,
        }).toEntity().isLocked,
        isTrue,
      );
      expect(
        UnitResponse.fromJson({
          'id': 'u1',
          'title': 'Unit',
          'lessonsCount': 3,
        }).toEntity().isLocked,
        isFalse,
      );
    });
  });
}
