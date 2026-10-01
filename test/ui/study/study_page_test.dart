import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/assignments/data/repository/assignments_repository.dart';
import 'package:student/core/assignments/domain/entity/assignment_entity.dart';
import 'package:student/core/assignments/domain/repository/i_assignments_repository.dart';
import 'package:student/core/chat/domain/entity/chat_room_entity.dart';
import 'package:student/core/chat/presentation/chat_rooms_controller.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/presentation/my_groups_controller.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/core/subscriptions/domain/entity/subscription_entity.dart';
import 'package:student/core/subscriptions/presentation/my_subscriptions_controller.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/chat/chat_room_screen.dart';
import 'package:student/ui/study/study_page.dart';
import 'package:student/ui/study/widget/schedule_picker.dart';

import '../../support/localized_app.dart';

class _Groups extends MyGroupsController {
  final List<GroupEntity> groups;

  _Groups(this.groups);

  @override
  Future<List<GroupEntity>> build() async => groups;
}

class _Subs extends MySubscriptionsController {
  final List<SubscriptionEntity> subs;

  _Subs(this.subs);

  @override
  Future<List<SubscriptionEntity>> build() async => subs;
}

/// Records the request it's asked to send; the list grows with it.
class _FakeAssignments implements IAssignmentsRepository {
  final List<AssignmentEntity> existing;
  final List<({String subscriptionId, List<ScheduleSlot> schedule})> sent = [];

  _FakeAssignments([this.existing = const []]);

  @override
  Future<List<AssignmentEntity>> getMyAssignments() async => [
    ...existing,
    for (final r in sent)
      AssignmentEntity(
        id: 'new',
        subscriptionId: r.subscriptionId,
        status: AssignmentStatus.pending,
        schedule: r.schedule,
      ),
  ];

  @override
  Future<AssignmentEntity> requestAssignment({
    required String subscriptionId,
    required List<ScheduleSlot> schedule,
  }) async {
    sent.add((subscriptionId: subscriptionId, schedule: schedule));
    return AssignmentEntity(
      id: 'new',
      subscriptionId: subscriptionId,
      status: AssignmentStatus.pending,
      schedule: schedule,
    );
  }
}

SubscriptionEntity _sub(String id, {int endsInDays = 20}) {
  final end = DateTime.now().add(Duration(days: endsInDays));
  return SubscriptionEntity(
    id: id,
    course: SubscriptionCourseEntity(id: 'c-$id', title: 'Course $id'),
    start: end.subtract(const Duration(days: 30)),
    end: end,
    isActive: true,
  );
}

const _english = GroupEntity(
  id: 'g1',
  title: 'Birlashgan o‘quvchilar',
  isActive: true,
  course: GroupCourseEntity(id: 'c1', title: 'General English'),
  primaryMentor: MentorEntity(id: 'm1', name: 'Azimov Samandar', rating: 0),
  supportMentors: [MentorEntity(id: 'm3', name: 'Karimova Dilnoza', rating: 0)],
  students: [
    GroupStudentEntity(id: 's1', firstName: 'Azima'),
    GroupStudentEntity(id: 's2', firstName: 'Jasur'),
    GroupStudentEntity(id: 's3', firstName: 'Lola'),
  ],
);

const _ielts = GroupEntity(
  id: 'g2',
  title: 'IELTS Evening',
  isActive: true,
  course: GroupCourseEntity(id: 'c2', title: 'IELTS'),
  primaryMentor: MentorEntity(id: 'm2', name: 'Jasur Karimov', rating: 0),
);

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required List<GroupEntity> groups,
  List<ChatRoomEntity> rooms = const [],
  List<SubscriptionEntity> subs = const [],
  _FakeAssignments? assignments,
}) async {
  tester.view.physicalSize = const Size(390, 1600) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      myGroupsControllerProvider.overrideWith(() => _Groups(groups)),
      chatRoomsProvider.overrideWith((ref) async => rooms),
      mySubscriptionsControllerProvider.overrideWith(() => _Subs(subs)),
      assignmentsRepositoryProvider.overrideWithValue(
        assignments ?? _FakeAssignments(),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: localizedApp(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: StudyPage()),
            ),
            GoRoute(
              path: ChatRoomScreen.path,
              builder: (_, state) => Scaffold(
                body: Text('room ${state.uri.queryParameters['roomId']}'),
              ),
            ),
            GoRoute(
              path: '/mentor/:id',
              builder: (_, state) =>
                  Scaffold(body: Text('mentor ${state.pathParameters['id']}')),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

ChatRoomEntity _room(String id, String groupId) => ChatRoomEntity(
  id: id,
  updatedAt: '',
  group: ChatGroupEntity(id: groupId, title: ''),
);

void main() {
  group('no group', () {
    testWidgets('no course invites the student to browse courses', (
      tester,
    ) async {
      final container = await _pump(tester, groups: []);

      expect(tester.takeException(), isNull);
      expect(
        find.text('Buy a course to choose your lesson times'),
        findsOneWidget,
      );
      await tester.tap(find.text('Browse courses'));
      await tester.pump();
      expect(container.read(navbarControllerProvider), 1);
    });

    testWidgets('an expired subscription counts as no course', (tester) async {
      await _pump(tester, groups: [], subs: [_sub('s1', endsInDays: -3)]);

      expect(
        find.text('Buy a course to choose your lesson times'),
        findsOneWidget,
      );
    });

    testWidgets('a request without a group: mentor note and task times', (
      tester,
    ) async {
      await _pump(
        tester,
        groups: [],
        subs: [_sub('s1')],
        assignments: _FakeAssignments(const [
          AssignmentEntity(
            id: 'a1',
            subscriptionId: 's1',
            status: AssignmentStatus.pending,
            courseTitle: 'General English',
            schedule: [
              ScheduleSlot(day: Weekday.mon, time: '11:00'),
              ScheduleSlot(day: Weekday.tue, time: '11:00'),
              ScheduleSlot(day: Weekday.wed, time: '11:00'),
            ],
          ),
        ]),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SchedulePicker), findsNothing);
      expect(find.text('Mentors'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('assignment-no-mentor')),
        findsOneWidget,
      );
      expect(find.text('Task submission times'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Tuesday'), findsOneWidget);
      expect(find.text('Wednesday'), findsOneWidget);
      expect(find.text('11:00'), findsNWidgets(3));
      expect(find.byKey(const ValueKey('task-time-icon')), findsNWidgets(3));
      // No group info.
      expect(find.text('Join the group'), findsNothing);
      expect(find.text('Lead mentor'), findsNothing);
    });

    testWidgets('an assigned mentor shows as the support mentor', (
      tester,
    ) async {
      await _pump(
        tester,
        groups: [],
        subs: [_sub('s1')],
        assignments: _FakeAssignments(const [
          AssignmentEntity(
            id: 'a1',
            subscriptionId: 's1',
            status: AssignmentStatus.active,
            mentor: MentorEntity(id: 'm9', name: 'Karimova Dilnoza', rating: 0),
            schedule: [ScheduleSlot(day: Weekday.fri, time: '18:00')],
          ),
        ]),
      );

      expect(find.text('Support mentor'), findsOneWidget);
      expect(find.text('Karimova Dilnoza'), findsOneWidget);
      expect(find.byKey(const ValueKey('assignment-no-mentor')), findsNothing);
      // The task times sit below the mentor.
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('task-times'))).dy,
        greaterThan(tester.getTopLeft(find.text('Karimova Dilnoza')).dy),
      );

      await tester.tap(find.text('Karimova Dilnoza'));
      await tester.pumpAndSettle();
      expect(find.text('mentor m9'), findsOneWidget);
    });

    testWidgets("a request for an expired subscription doesn't count", (
      tester,
    ) async {
      await _pump(
        tester,
        groups: [],
        subs: [_sub('s1', endsInDays: -3)],
        assignments: _FakeAssignments(const [
          AssignmentEntity(
            id: 'a1',
            subscriptionId: 's1',
            status: AssignmentStatus.pending,
          ),
        ]),
      );

      expect(
        find.text('Buy a course to choose your lesson times'),
        findsOneWidget,
      );
    });
  });

  group('schedule picker', () {
    Finder confirm() => find.byKey(const ValueKey('schedule-confirm'));
    bool confirmEnabled(WidgetTester tester) =>
        tester.widget<AppFlatPillButton>(confirm()).onTap != null;

    Future<void> pick(WidgetTester tester, String day, String time) async {
      await tester.tap(find.byKey(ValueKey('day-$day')));
      await tester.pump();
      await tester.tap(find.byKey(ValueKey('time-$time')));
      await tester.pump();
    }

    testWidgets('a running subscription without a request gets the picker', (
      tester,
    ) async {
      await _pump(tester, groups: [], subs: [_sub('s1')]);

      expect(tester.takeException(), isNull);
      expect(find.byType(SchedulePicker), findsOneWidget);
      expect(find.text("You'll join a group soon"), findsOneWidget);
      expect(find.text('Weekdays'), findsOneWidget);
      // Opens on Monday with every hour on offer.
      expect(find.text('Time — Monday'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);
      expect(find.text('Confirm (0/3)'), findsOneWidget);
      expect(confirmEnabled(tester), isFalse);
    });

    testWidgets('picking a day switches the time heading', (tester) async {
      await _pump(tester, groups: [], subs: [_sub('s1')]);

      await tester.tap(find.byKey(const ValueKey('day-wed')));
      await tester.pump();

      expect(find.text('Time — Wednesday'), findsOneWidget);
    });

    testWidgets('three picks enable Confirm; a fourth is refused', (
      tester,
    ) async {
      await _pump(tester, groups: [], subs: [_sub('s1')]);

      await pick(tester, 'mon', '09:00');
      await pick(tester, 'wed', '14:00');
      expect(confirmEnabled(tester), isFalse);
      await pick(tester, 'fri', '18:00');

      expect(find.text('Confirm (3/3)'), findsOneWidget);
      expect(confirmEnabled(tester), isTrue);

      await pick(tester, 'sat', '10:00');
      await tester.pumpAndSettle();
      expect(find.text('Confirm (3/3)'), findsOneWidget);
      expect(
        find.text('You can choose only 3 days — remove one first'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('a second time on the same day replaces the first', (
      tester,
    ) async {
      await _pump(tester, groups: [], subs: [_sub('s1')]);

      await pick(tester, 'mon', '09:00');
      await pick(tester, 'mon', '15:00');

      expect(find.text('Confirm (1/3)'), findsOneWidget);
      expect(find.byKey(const ValueKey('chosen-mon-15:00')), findsOneWidget);
      expect(find.byKey(const ValueKey('chosen-mon-09:00')), findsNothing);
    });

    testWidgets('swapping a time on a full set is allowed', (tester) async {
      await _pump(tester, groups: [], subs: [_sub('s1')]);

      await pick(tester, 'mon', '09:00');
      await pick(tester, 'wed', '14:00');
      await pick(tester, 'fri', '18:00');
      await pick(tester, 'wed', '16:00');
      await tester.pumpAndSettle();

      expect(find.text('Confirm (3/3)'), findsOneWidget);
      expect(find.byKey(const ValueKey('chosen-wed-16:00')), findsOneWidget);
      expect(find.byKey(const ValueKey('chosen-wed-14:00')), findsNothing);
      expect(find.textContaining('You can choose only'), findsNothing);
    });

    testWidgets('tapping a picked time again unpicks it', (tester) async {
      await _pump(tester, groups: [], subs: [_sub('s1')]);

      await pick(tester, 'mon', '09:00');
      expect(find.text('Confirm (1/3)'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('time-09:00')));
      await tester.pump();

      expect(find.text('Confirm (0/3)'), findsOneWidget);
    });

    testWidgets('Confirm sends the slots, then the student waits', (
      tester,
    ) async {
      final assignments = _FakeAssignments();
      await _pump(
        tester,
        groups: [],
        subs: [_sub('s1')],
        assignments: assignments,
      );

      await pick(tester, 'mon', '09:00');
      await pick(tester, 'wed', '14:00');
      await pick(tester, 'fri', '18:00');
      await tester.tap(confirm());
      await tester.pumpAndSettle();

      expect(assignments.sent.single.subscriptionId, 's1');
      expect(assignments.sent.single.schedule, const [
        ScheduleSlot(day: Weekday.mon, time: '09:00'),
        ScheduleSlot(day: Weekday.wed, time: '14:00'),
        ScheduleSlot(day: Weekday.fri, time: '18:00'),
      ]);
      expect(find.byType(SchedulePicker), findsNothing);
      expect(find.text('Task submission times'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });

  group('in a group', () {
    testWidgets('shows the group, its members and its mentors', (tester) async {
      await _pump(tester, groups: [_english], rooms: [_room('r1', 'g1')]);

      expect(tester.takeException(), isNull);
      expect(find.text('Birlashgan o‘quvchilar'), findsOneWidget);
      expect(find.text('3 members'), findsOneWidget);
      expect(find.text('Join the group'), findsOneWidget);
      expect(find.text('Mentors'), findsOneWidget);
      expect(find.text('Lead mentor'), findsOneWidget);
      expect(find.text('Azimov Samandar'), findsOneWidget);
      expect(find.text('Support mentor'), findsOneWidget);
      expect(find.text('Karimova Dilnoza'), findsOneWidget);
    });

    testWidgets('no support mentor means no support row', (tester) async {
      await _pump(tester, groups: [_ielts]);

      expect(find.text('Lead mentor'), findsOneWidget);
      expect(find.text('Support mentor'), findsNothing);
    });

    testWidgets("each group's button opens its own chat room", (tester) async {
      await _pump(
        tester,
        groups: [_english, _ielts],
        rooms: [_room('r1', 'g1'), _room('r2', 'g2')],
      );

      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('group-g2')),
          matching: find.text('Join the group'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('room r2'), findsOneWidget);
    });

    testWidgets('a group with no room of its own has no chat button', (
      tester,
    ) async {
      await _pump(
        tester,
        groups: [_english, _ielts],
        rooms: [_room('r1', 'g1')],
      );

      expect(find.text('Join the group'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('group-g2')),
          matching: find.text('Join the group'),
        ),
        findsNothing,
      );
    });

    testWidgets("a request for the group's course joins its section", (
      tester,
    ) async {
      await _pump(
        tester,
        groups: [_ielts],
        subs: [_sub('s1')],
        assignments: _FakeAssignments(const [
          AssignmentEntity(
            id: 'a1',
            subscriptionId: 's1',
            status: AssignmentStatus.active,
            courseId: 'c2',
            mentor: MentorEntity(id: 'm9', name: 'Karimova Dilnoza', rating: 0),
            schedule: [ScheduleSlot(day: Weekday.mon, time: '11:00')],
          ),
        ]),
      );

      // Under the group's own mentors, with one Mentors heading only.
      expect(find.text('Mentors'), findsOneWidget);
      expect(find.text('Lead mentor'), findsOneWidget);
      expect(find.text('Support mentor'), findsOneWidget);
      expect(find.text('Karimova Dilnoza'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('group-g2')),
          matching: find.byKey(const ValueKey('task-times')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a request for another course gets its own section', (
      tester,
    ) async {
      await _pump(
        tester,
        groups: [_ielts],
        subs: [_sub('s1')],
        assignments: _FakeAssignments(const [
          AssignmentEntity(
            id: 'a1',
            subscriptionId: 's1',
            status: AssignmentStatus.pending,
            courseId: 'c1',
            schedule: [ScheduleSlot(day: Weekday.mon, time: '11:00')],
          ),
        ]),
      );

      expect(find.text('Mentors'), findsNWidgets(2));
      expect(find.byKey(const ValueKey('assignment-a1')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('assignment-no-mentor')),
        findsOneWidget,
      );
    });

    testWidgets('tapping a mentor opens their profile', (tester) async {
      await _pump(tester, groups: [_english]);

      await tester.tap(find.text('Azimov Samandar'));
      await tester.pumpAndSettle();
      expect(find.text('mentor m1'), findsOneWidget);
    });
  });
}
