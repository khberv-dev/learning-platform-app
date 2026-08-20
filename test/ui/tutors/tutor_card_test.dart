import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/shared/widget/rating_stars.dart';
import 'package:student/ui/tutors/widget/tutor_card.dart';

import '../../support/localized_app.dart';

TutorEntity _tutor({
  String name = 'Botir Jobirovich',
  double rating = 4,
  int feedbackCount = 4,
  String? profession = 'Ingiliz tili',
  String? avatarUrl,
}) => TutorEntity(
  id: '1',
  name: name,
  rating: rating,
  feedbackCount: feedbackCount,
  status: 'active',
  profession: profession,
  avatarUrl: avatarUrl,
);

Widget _host(Widget child) => localizedApp(
  routerConfig: GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(body: Center(child: child)),
      ),
      GoRoute(
        path: '/tutor/:id',
        builder: (_, s) => Scaffold(
          body: Center(child: Text('profile ${s.pathParameters['id']}')),
        ),
      ),
    ],
  ),
);

int _filledStars(WidgetTester tester) => tester
    .widgetList<Container>(
      find.descendant(
        of: find.byType(RatingStars),
        matching: find.byType(Container),
      ),
    )
    .where((c) => (c.decoration as BoxDecoration).color == AppColors.ratingFill)
    .length;

void main() {
  group('RatingStars', () {
    testWidgets('always draws five badges', (tester) async {
      await tester.pumpWidget(_host(const RatingStars(rating: 3)));
      expect(
        find.descendant(
          of: find.byType(RatingStars),
          matching: find.byType(Container),
        ),
        findsNWidgets(RatingStars.count),
      );
    });

    testWidgets('fills to the nearest whole star', (tester) async {
      for (final (rating, expected) in [
        (0.0, 0),
        (0.4, 0),
        (0.6, 1),
        (3.5, 4),
        (5.0, 5),
      ]) {
        await tester.pumpWidget(_host(RatingStars(rating: rating)));
        expect(_filledStars(tester), expected, reason: 'rating $rating');
      }
    });

    testWidgets('clamps ratings outside the scale', (tester) async {
      await tester.pumpWidget(_host(const RatingStars(rating: 9)));
      expect(_filledStars(tester), RatingStars.count);

      await tester.pumpWidget(_host(const RatingStars(rating: -3)));
      expect(_filledStars(tester), 0);
    });
  });

  group('TutorCard', () {
    testWidgets('shows name, profession and review count', (tester) async {
      await tester.pumpWidget(_host(TutorCard(tutor: _tutor())));

      expect(tester.takeException(), isNull);
      expect(find.text('Botir Jobirovich'), findsOneWidget);
      expect(find.text('Ingiliz tili'), findsOneWidget);
      expect(find.text('4.0  ·  4 reviews'), findsOneWidget);
    });

    testWidgets('omits the chip when the tutor has no profession', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(TutorCard(tutor: _tutor(profession: null))),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Ingiliz tili'), findsNothing);
    });

    testWidgets('falls back to initials without a photo', (tester) async {
      await tester.pumpWidget(_host(TutorCard(tutor: _tutor())));

      expect(find.text('BJ'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('a single-word name still yields an initial', (tester) async {
      await tester.pumpWidget(_host(TutorCard(tutor: _tutor(name: 'Botir'))));

      expect(tester.takeException(), isNull);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('opens the tutor profile on tap', (tester) async {
      await tester.pumpWidget(_host(TutorCard(tutor: _tutor())));

      await tester.tap(find.byType(TutorCard));
      await tester.pumpAndSettle();

      expect(find.text('profile 1'), findsOneWidget);
    });

    testWidgets('a long name ellipsizes rather than overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: TutorCard(
              tutor: _tutor(
                name: 'Botir Jobirovich Abdurahmonov Toshmatov Qodirov',
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
