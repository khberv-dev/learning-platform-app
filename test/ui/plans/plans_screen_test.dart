import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/core/plans/data/model/plan_response.dart';
import 'package:student/core/plans/data/repository/plans_repository.dart';
import 'package:student/core/plans/domain/entity/plan_entity.dart';
import 'package:student/core/plans/domain/repository/i_plans_repository.dart';
import 'package:student/ui/plans/plans_screen.dart';

const _plans = [
  PlanEntity(
    id: 'pl1',
    title: 'Standart',
    price: 250000,
    month: 3,
    hasMentor: false,
  ),
  PlanEntity(
    id: 'pl2',
    title: 'Premium',
    price: 900000,
    month: 12,
    hasMentor: true,
  ),
  PlanEntity(
    id: 'pl3',
    title: 'Sinov',
    price: 90000,
    month: 1,
    hasMentor: false,
  ),
];

class _Repo implements IPlansRepository {
  final List<PlanEntity> plans;
  final Object? error;
  final requested = <String>[];

  _Repo({this.plans = _plans, this.error});

  @override
  Future<List<PlanEntity>> getCoursePlans(String courseId) async {
    requested.add(courseId);
    if (error != null) throw error!;
    return plans;
  }
}

Future<void> _pump(WidgetTester tester, _Repo repo) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [plansRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const PlansScreen(courseId: 'c1'),
            ),
            GoRoute(
              path: '/payment-types',
              builder: (_, state) => Scaffold(
                body: Center(
                  child: Text('pay ${state.uri.queryParameters['planId']}'),
                ),
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
  group('PlanResponse', () {
    test('reads the documented shape', () {
      final plan = PlanResponse.fromJson({
        'id': 'pl1',
        'title': 'Standart',
        'price': 250000,
        'month': 3,
        'hasMentor': false,
        'isActive': true,
      }).toEntity();

      expect(plan.id, 'pl1');
      expect(plan.title, 'Standart');
      expect(plan.price, 250000);
      expect(plan.month, 3);
      expect(plan.hasMentor, isFalse);
    });

    test('tolerates missing numbers and flags', () {
      final plan = PlanResponse.fromJson({'id': 7}).toEntity();

      expect(plan.id, '7');
      expect(plan.price, 0);
      expect(plan.month, 0);
      expect(plan.hasMentor, isFalse);
    });
  });

  group('PlansScreen', () {
    testWidgets('lists the plans for the course', (tester) async {
      final repo = _Repo();
      await _pump(tester, repo);

      expect(tester.takeException(), isNull);
      expect(repo.requested, ['c1']);
      expect(find.byType(PlanCard), findsNWidgets(3));
      expect(find.text('Standart'), findsOneWidget);
      expect(find.text("250 000 so'm"), findsOneWidget);
    });

    testWidgets('pluralises the duration', (tester) async {
      await _pump(tester, _Repo());

      expect(find.text('3 months'), findsOneWidget);
      expect(find.text('12 months'), findsOneWidget);
      expect(find.text('1 month'), findsOneWidget);
    });

    testWidgets('flags only the plans that include a mentor', (tester) async {
      await _pump(tester, _Repo());

      expect(find.text('With mentor'), findsOneWidget);
    });

    testWidgets('opens checkout against the chosen plan, not the course', (
      tester,
    ) async {
      await _pump(tester, _Repo());

      await tester.tap(find.text('Premium'));
      await tester.pumpAndSettle();

      expect(find.text('pay pl2'), findsOneWidget);
    });

    testWidgets('shows a placeholder when the course is not on sale', (
      tester,
    ) async {
      await _pump(tester, _Repo(plans: const []));

      expect(find.text('No plans yet'), findsOneWidget);
      expect(find.byType(PlanCard), findsNothing);
    });

    testWidgets('surfaces the API message on failure', (tester) async {
      await _pump(
        tester,
        _Repo(
          error: DioException(
            requestOptions: RequestOptions(path: 'courses/c1/plans'),
            response: Response(
              statusCode: 404,
              data: {'message': 'Kurs topilmadi'},
              requestOptions: RequestOptions(path: 'courses/c1/plans'),
            ),
          ),
        ),
      );

      expect(find.text("Couldn't load the plans"), findsOneWidget);
      expect(find.text('Kurs topilmadi'), findsOneWidget);
    });
  });
}
