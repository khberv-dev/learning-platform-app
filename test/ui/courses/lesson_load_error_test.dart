import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/ui/courses/widget/lesson_load_error.dart';
import 'package:student/ui/plans/plans_screen.dart';

import '../../support/localized_app.dart';

DioException _status(int code, String message) => DioException(
  requestOptions: RequestOptions(
    path: 'student/courses/c1/units/u1/lessons/l1',
  ),
  response: Response(
    requestOptions: RequestOptions(
      path: 'student/courses/c1/units/u1/lessons/l1',
    ),
    statusCode: code,
    data: {'message': message, 'statusCode': code},
  ),
);

Future<void> _pump(WidgetTester tester, Object error) => tester.pumpWidget(
  localizedApp(
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: LessonLoadError(error: error, courseId: 'c1'),
          ),
        ),
        GoRoute(
          path: PlansScreen.path,
          builder: (_, state) => Scaffold(
            body: Text('plans ${state.uri.queryParameters['courseId']}'),
          ),
        ),
      ],
    ),
  ),
);

void main() {
  testWidgets('a 403 asks the student to buy a plan', (tester) async {
    await _pump(tester, _status(403, 'Siz bu kursga yozilmagansiz'));
    await tester.pumpAndSettle();

    expect(find.text("You're not enrolled in this course"), findsOneWidget);

    await tester.tap(find.text('Buy a plan'));
    await tester.pumpAndSettle();
    expect(find.text('plans c1'), findsOneWidget);
  });

  testWidgets('any other failure shows the error, with no buy button', (
    tester,
  ) async {
    await _pump(tester, _status(500, 'Server exploded'));
    await tester.pumpAndSettle();

    expect(find.text('Server exploded'), findsOneWidget);
    expect(find.text('Buy a plan'), findsNothing);
  });
}
