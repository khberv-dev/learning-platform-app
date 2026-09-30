import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/plans/data/repository/plans_repository.dart';

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

void main() {
  test('reads plans from the paginated envelope', () async {
    final requests = <RequestOptions>[];
    final repo = PlansRepository(
      dio: _dioReturning({
        'data': [
          {
            'id': '48e64bd1',
            'title': 'Standard',
            'price': 99000,
            'month': 1,
            'hasSubscription': false,
            'isActive': true,
          },
          {
            'id': '79dc8aae',
            'title': 'Pro',
            'price': 1000000,
            'month': 3,
            'hasSubscription': true,
            'isActive': true,
          },
        ],
        'total': 2,
        'page': 1,
        'limit': 10,
        'totalPages': 1,
      }, requests),
    );

    final plans = await repo.getCoursePlans('95a0b4ea');

    expect(requests.single.path, 'student/courses/95a0b4ea/plans');
    // Past the API's 10-per-page default, so no plan is cut off.
    expect(requests.single.queryParameters['limit'], 100);
    expect(plans.map((p) => p.title), ['Standard', 'Pro']);
    expect(plans.last.price, 1000000);
    expect(plans.last.month, 3);
  });

  test('leaves out plans taken off sale', () async {
    final repo = PlansRepository(
      dio: _dioReturning({
        'data': [
          {'id': 'a', 'title': 'On sale', 'price': 1, 'month': 1},
          {
            'id': 'b',
            'title': 'Retired',
            'price': 1,
            'month': 1,
            'isActive': false,
          },
        ],
      }, []),
    );

    final plans = await repo.getCoursePlans('c1');

    expect(plans.map((p) => p.title), ['On sale']);
  });

  test('an empty page is no plans, not an error', () async {
    final repo = PlansRepository(
      dio: _dioReturning({'data': [], 'total': 0}, []),
    );

    expect(await repo.getCoursePlans('c1'), isEmpty);
  });
}
