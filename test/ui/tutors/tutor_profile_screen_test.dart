import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/core/tutors/data/repository/tutors_repository.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/core/tutors/domain/repository/i_tutors_repository.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/ui/tutors/tutor_profile_screen.dart';

import '../../support/localized_app.dart';

class _Repo implements ITutorsRepository {
  final TutorEntity tutor;

  _Repo(this.tutor);

  @override
  Future<TutorEntity> getTutor(String id) async => tutor;

  @override
  dynamic noSuchMethod(Invocation invocation) async => <Never>[];
}

TutorEntity _tutor({String? profession = 'General english'}) => TutorEntity(
  id: '1',
  name: 'Botir Jobirovich',
  rating: 0,
  feedbackCount: 0,
  status: 'active',
  profession: profession,
);

Future<void> _pump(WidgetTester tester, TutorEntity tutor) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [tutorsRepositoryProvider.overrideWithValue(_Repo(tutor))],
      child: localizedApp(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const TutorProfileScreen(tutorId: '1'),
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
  testWidgets('names the tutor in the header and leads with the subject', (
    tester,
  ) async {
    await _pump(tester, _tutor());

    expect(tester.takeException(), isNull);
    expect(find.text('General english'), findsOneWidget);
    // Once in the header, once beside the avatar.
    expect(find.text('Botir Jobirovich'), findsNWidgets(2));
  });

  testWidgets('falls back to the name when no subject is set', (tester) async {
    await _pump(tester, _tutor(profession: null));

    expect(tester.takeException(), isNull);
    expect(find.text('General english'), findsNothing);
    // Header, headline and the row under it.
    expect(find.text('Botir Jobirovich'), findsNWidgets(3));
  });

  testWidgets('shows the empty reviews state', (tester) async {
    await _pump(tester, _tutor());

    expect(find.text('Student reviews'), findsOneWidget);
    expect(find.text('No reviews yet'), findsOneWidget);
  });

  testWidgets('offers the booking action', (tester) async {
    await _pump(tester, _tutor());

    expect(find.text('Book tutor'), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
  });
}
