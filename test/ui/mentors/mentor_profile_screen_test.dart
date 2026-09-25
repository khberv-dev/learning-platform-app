import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/core/mentors/data/repository/mentors_repository.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/core/mentors/domain/repository/i_mentors_repository.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/ui/mentors/mentor_profile_screen.dart';

import '../../support/localized_app.dart';

class _Repo implements IMentorsRepository {
  final MentorEntity mentor;

  _Repo(this.mentor);

  @override
  Future<MentorEntity> getMentor(String id) async => mentor;

  @override
  dynamic noSuchMethod(Invocation invocation) async => <Never>[];
}

MentorEntity _mentor({String? profession = 'General english'}) => MentorEntity(
  id: '1',
  name: 'Botir Jobirovich',
  rating: 0,
  profession: profession,
);

Future<void> _pump(WidgetTester tester, MentorEntity mentor) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [mentorsRepositoryProvider.overrideWithValue(_Repo(mentor))],
      child: localizedApp(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const MentorProfileScreen(mentorId: '1'),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('names the mentor in the header and leads with the subject', (
    tester,
  ) async {
    await _pump(tester, _mentor());

    expect(tester.takeException(), isNull);
    expect(find.text('General english'), findsOneWidget);
    // Once in the header, once beside the avatar.
    expect(find.text('Botir Jobirovich'), findsNWidgets(2));
  });

  testWidgets('falls back to the name when no subject is set', (tester) async {
    await _pump(tester, _mentor(profession: null));

    expect(tester.takeException(), isNull);
    expect(find.text('General english'), findsNothing);
    // Header, headline and the row under it.
    expect(find.text('Botir Jobirovich'), findsNWidgets(3));
  });

  testWidgets('shows the empty reviews state', (tester) async {
    await _pump(tester, _mentor());

    expect(find.text('Student reviews'), findsOneWidget);
    expect(find.text('No reviews yet'), findsOneWidget);
  });

  testWidgets('has no booking action — 1:1 booking is gone', (tester) async {
    await _pump(tester, _mentor());

    expect(find.text('Book mentor'), findsNothing);
    expect(find.byType(AppButton), findsOneWidget);
  });

  testWidgets('offers a leave-a-review action', (tester) async {
    await _pump(tester, _mentor());

    expect(find.text('Leave a review'), findsOneWidget);
  });
}
