import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/chat/domain/entity/chat_room_entity.dart';
import 'package:student/core/chat/presentation/chat_rooms_controller.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/presentation/my_groups_controller.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/ui/chat/chat_room_screen.dart';
import 'package:student/ui/study/study_page.dart';

import '../../support/localized_app.dart';

class _Groups extends MyGroupsController {
  final List<GroupEntity> groups;

  _Groups(this.groups);

  @override
  Future<List<GroupEntity>> build() async => groups;
}

class _Mine extends MyCoursesController {
  final List<MyCourseEntity> courses;

  _Mine(this.courses);

  @override
  Future<List<MyCourseEntity>> build() async => courses;
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
  List<MyCourseEntity> mine = const [],
}) async {
  tester.view.physicalSize = const Size(390, 1600) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      myGroupsControllerProvider.overrideWith(() => _Groups(groups)),
      chatRoomsProvider.overrideWith((ref) async => rooms),
      myCoursesControllerProvider.overrideWith(() => _Mine(mine)),
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

    testWidgets('owning a course says a group is on its way instead', (
      tester,
    ) async {
      await _pump(
        tester,
        groups: [],
        mine: const [
          MyCourseEntity(
            enrollmentId: 'e',
            courseId: 'c1',
            title: 'General English',
            lessonsCount: 8,
            progress: 0,
          ),
        ],
      );

      expect(find.text("You'll be added to a group soon"), findsOneWidget);
      expect(find.text('Browse courses'), findsNothing);
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

    testWidgets('tapping a mentor opens their profile', (tester) async {
      await _pump(tester, groups: [_english]);

      await tester.tap(find.text('Azimov Samandar'));
      await tester.pumpAndSettle();
      expect(find.text('mentor m1'), findsOneWidget);
    });
  });
}
