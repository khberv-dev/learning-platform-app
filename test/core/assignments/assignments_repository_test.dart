import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/assignments/data/repository/assignments_repository.dart';
import 'package:student/core/assignments/domain/entity/assignment_entity.dart';

/// A Dio that answers every request with [body], recording what was asked.
Dio _dioReturning(Object body, List<RequestOptions> requests) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        handler.resolve(
          Response(requestOptions: options, statusCode: 200, data: body),
        );
      },
    ),
  );
  return dio;
}

const _assignmentJson = {
  'id': 'a1',
  'status': 'pending',
  'schedule': [
    {'mon': '09:00'},
    {'wed': '14:00'},
    {'fri': '18:00'},
  ],
  'subscription': {
    'id': 's1',
    'course': {'id': 'c1', 'title': 'General English'},
  },
  'mentor': null,
};

void main() {
  test('reads the student\'s requests from the paginated envelope', () async {
    final requests = <RequestOptions>[];
    final repo = AssignmentsRepository(
      dio: _dioReturning({
        'data': [
          _assignmentJson,
          {..._assignmentJson, 'id': 'a2', 'status': 'active'},
        ],
        'total': 2,
      }, requests),
    );

    final assignments = await repo.getMyAssignments();

    expect(requests.single.method, 'GET');
    expect(requests.single.path, 'student/assignments');
    expect(requests.single.queryParameters['limit'], 100);
    expect(assignments.first.subscriptionId, 's1');
    expect(assignments.first.courseId, 'c1');
    expect(assignments.first.courseTitle, 'General English');
    expect(assignments.first.mentor, isNull);
    expect(assignments.first.status, AssignmentStatus.pending);
    expect(assignments.last.status, AssignmentStatus.active);
    expect(assignments.first.schedule, const [
      ScheduleSlot(day: Weekday.mon, time: '09:00'),
      ScheduleSlot(day: Weekday.wed, time: '14:00'),
      ScheduleSlot(day: Weekday.fri, time: '18:00'),
    ]);
  });

  test('sends the request in the API\'s { day: time } shape', () async {
    final requests = <RequestOptions>[];
    final repo = AssignmentsRepository(
      dio: _dioReturning(_assignmentJson, requests),
    );

    final created = await repo.requestAssignment(
      subscriptionId: 's1',
      schedule: const [
        ScheduleSlot(day: Weekday.mon, time: '09:00'),
        ScheduleSlot(day: Weekday.wed, time: '14:00'),
        ScheduleSlot(day: Weekday.fri, time: '18:00'),
      ],
    );

    expect(requests.single.method, 'POST');
    expect(requests.single.path, 'student/assignments');
    expect(requests.single.data, {
      'subscriptionId': 's1',
      'schedule': [
        {'mon': '09:00'},
        {'wed': '14:00'},
        {'fri': '18:00'},
      ],
    });
    expect(created.id, 'a1');
  });

  test('skips slots with an unknown day or a non-text time', () async {
    final repo = AssignmentsRepository(
      dio: _dioReturning({
        'data': [
          {
            ..._assignmentJson,
            'schedule': [
              {'mon': '09:00'},
              {'xyz': '10:00'},
              {'tue': 10},
            ],
          },
        ],
      }, []),
    );

    final assignments = await repo.getMyAssignments();

    expect(assignments.single.schedule, const [
      ScheduleSlot(day: Weekday.mon, time: '09:00'),
    ]);
  });

  test('reads the assigned mentor', () async {
    final repo = AssignmentsRepository(
      dio: _dioReturning({
        'data': [
          {
            ..._assignmentJson,
            'status': 'active',
            'mentor': {
              'id': 'm9',
              'firstName': 'Dilnoza',
              'lastName': 'Karimova',
            },
          },
        ],
      }, []),
    );

    final assignment = (await repo.getMyAssignments()).single;

    expect(assignment.mentor?.id, 'm9');
    expect(assignment.mentor?.name, 'Dilnoza Karimova');
  });
}
