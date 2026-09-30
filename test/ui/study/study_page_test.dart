import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/chat/domain/entity/chat_room_entity.dart';
import 'package:student/core/chat/presentation/chat_rooms_controller.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/presentation/my_groups_controller.dart';
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

const _english = GroupEntity(
  id: 'g1',
  title: 'A1 Morning',
  isActive: true,
  course: GroupCourseEntity(id: 'c1', title: 'General English'),
  primaryMentor: MentorEntity(id: 'm1', name: 'Dilnoza Rahimova', rating: 0),
);

const _ielts = GroupEntity(
  id: 'g2',
  title: 'IELTS Evening',
  isActive: true,
  course: GroupCourseEntity(id: 'c2', title: 'IELTS'),
  primaryMentor: MentorEntity(id: 'm2', name: 'Jasur Karimov', rating: 0),
);

Future<void> _pump(
  WidgetTester tester, {
  required List<GroupEntity> groups,
  List<ChatRoomEntity> rooms = const [],
}) async {
  tester.view.physicalSize = const Size(390, 1400) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myGroupsControllerProvider.overrideWith(() => _Groups(groups)),
        chatRoomsProvider.overrideWith((ref) async => rooms),
      ],
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
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no groups shows the buy-a-course message', (tester) async {
    await _pump(tester, groups: []);

    expect(find.text("You haven't joined a group yet"), findsOneWidget);
  });

  testWidgets('lists every group with its course and mentor', (tester) async {
    await _pump(tester, groups: [_english, _ielts]);

    expect(tester.takeException(), isNull);
    expect(find.text('A1 Morning'), findsOneWidget);
    expect(find.text('General English'), findsOneWidget);
    expect(find.text('Dilnoza Rahimova'), findsOneWidget);
    expect(find.text('IELTS Evening'), findsOneWidget);
    expect(find.text('Jasur Karimov'), findsOneWidget);
  });

  testWidgets("each group's chat button opens that group's room", (
    tester,
  ) async {
    await _pump(
      tester,
      groups: [_english, _ielts],
      rooms: const [
        ChatRoomEntity(
          id: 'r1',
          updatedAt: '',
          group: ChatGroupEntity(id: 'g1', title: 'A1 Morning'),
        ),
        ChatRoomEntity(
          id: 'r2',
          updatedAt: '',
          group: ChatGroupEntity(id: 'g2', title: 'IELTS Evening'),
        ),
      ],
    );

    final ielts = find.byKey(const ValueKey('group-g2'));
    await tester.tap(
      find.descendant(of: ielts, matching: find.text('Open chat')),
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
      rooms: const [
        ChatRoomEntity(
          id: 'r1',
          updatedAt: '',
          group: ChatGroupEntity(id: 'g1', title: 'A1 Morning'),
        ),
      ],
    );

    expect(find.text('Open chat'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('group-g2')),
        matching: find.text('Open chat'),
      ),
      findsNothing,
    );
  });
}
