import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/groups/data/model/group_response.dart';

void main() {
  group('GroupResponse', () {
    test('reads the course and the flat primary mentor', () {
      final group = GroupResponse.fromJson({
        'id': 'g1',
        'title': 'A1 Morning',
        'course': {'id': 'c1', 'title': 'General English'},
        'primaryMentor': {
          'id': 'm1',
          'firstName': 'Dilnoza',
          'lastName': 'Rahimova',
          'avatar': 'https://storage.example/m1.jpg',
        },
        'students': [
          {'id': 's1', 'firstName': 'Azima', 'joinedAt': '2026-09-01'},
        ],
      }).toEntity();

      expect(group.course?.id, 'c1');
      expect(group.course?.title, 'General English');
      expect(group.primaryMentor?.id, 'm1');
      expect(group.primaryMentor?.name, 'Dilnoza Rahimova');
      expect(group.students.single.firstName, 'Azima');
    });

    test('a group without a mentor or course has neither', () {
      final group = GroupResponse.fromJson({
        'id': 'g1',
        'title': 'A1 Morning',
        'primaryMentor': null,
      }).toEntity();

      expect(group.primaryMentor, isNull);
      expect(group.course, isNull);
    });

    test('falls back to the primary entry of an older mentors list', () {
      final group = GroupResponse.fromJson({
        'id': 'g1',
        'title': 'A1 Morning',
        'mentors': [
          {
            'role': 'support',
            'mentor': {'id': 'm2', 'firstName': 'Support'},
          },
          {
            'role': 'primary',
            'mentor': {'id': 'm1', 'firstName': 'Primary'},
          },
        ],
      }).toEntity();

      expect(group.primaryMentor?.id, 'm1');
    });
  });

  group('support mentors', () {
    test('read from a flat supportMentors list', () {
      final group = GroupResponse.fromJson({
        'id': 'g1',
        'title': 'A1 Morning',
        'supportMentors': [
          {'id': 'm2', 'firstName': 'Dilnoza', 'lastName': 'Karimova'},
        ],
      }).toEntity();

      expect(group.supportMentors.single.name, 'Dilnoza Karimova');
    });

    test('or from the support entries of the older mentors list', () {
      final group = GroupResponse.fromJson({
        'id': 'g1',
        'title': 'A1 Morning',
        'mentors': [
          {
            'role': 'primary',
            'mentor': {'id': 'm1', 'firstName': 'Primary'},
          },
          {
            'role': 'support',
            'mentor': {'id': 'm2', 'firstName': 'Support'},
          },
        ],
      }).toEntity();

      expect(group.primaryMentor?.id, 'm1');
      expect(group.supportMentors.map((m) => m.id), ['m2']);
    });

    test('none when the API sends neither', () {
      final group = GroupResponse.fromJson({
        'id': 'g1',
        'title': 'A1 Morning',
        'primaryMentor': {'id': 'm1', 'firstName': 'Primary'},
      }).toEntity();

      expect(group.supportMentors, isEmpty);
    });
  });
}
