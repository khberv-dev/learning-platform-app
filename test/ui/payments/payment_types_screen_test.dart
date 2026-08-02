import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/core/payments/data/repository/payments_repository.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/core/payments/domain/entity/payment_type_entity.dart';
import 'package:student/core/payments/domain/repository/i_payments_repository.dart';
import 'package:student/shared/url_launcher.dart';
import 'package:student/shared/widget/back_icon_button.dart';
import 'package:student/ui/payments/payment_types_screen.dart';

const _payme = PaymentTypeEntity(
  id: 'pt1',
  title: 'Payme',
  checkoutUrl: 'https://payme.uz/checkout',
);
const _click = PaymentTypeEntity(
  id: 'pt2',
  title: 'Click',
  checkoutUrl: 'https://click.uz/pay',
);

const _pending = PaymentEntity(id: 'pa1', status: PaymentStatus.created);

class _Repo implements IPaymentsRepository {
  final List<PaymentTypeEntity> types;
  final Object? requestError;
  final Object? selectError;

  /// Lets a test hand back a different URL than the one listed.
  final String? echoedUrl;

  final requestedCourses = <String>[];
  final selections = <({String paymentId, String paymentTypeId})>[];

  _Repo({
    this.types = const [_payme, _click],
    this.requestError,
    this.selectError,
    this.echoedUrl,
  });

  @override
  Future<PaymentRequestEntity> requestPayment(String courseId) async {
    requestedCourses.add(courseId);
    if (requestError != null) throw requestError!;
    return PaymentRequestEntity(payment: _pending, paymentTypes: types);
  }

  @override
  Future<PaymentEntity> selectPaymentType({
    required String paymentId,
    required String paymentTypeId,
  }) async {
    selections.add((paymentId: paymentId, paymentTypeId: paymentTypeId));
    if (selectError != null) throw selectError!;

    final chosen = types.firstWhere((t) => t.id == paymentTypeId);
    return PaymentEntity(
      id: paymentId,
      status: PaymentStatus.created,
      paymentType: echoedUrl == null
          ? chosen
          : PaymentTypeEntity(
              id: chosen.id,
              title: chosen.title,
              checkoutUrl: echoedUrl,
            ),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repo repo, {
  List<Uri>? opened,
  bool launchSucceeds = true,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        paymentsRepositoryProvider.overrideWithValue(repo),
        urlLauncherProvider.overrideWithValue((uri) async {
          opened?.add(uri);
          return launchSucceeds;
        }),
      ],
      child: MaterialApp.router(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, _) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () =>
                        context.push('${PaymentTypesScreen.path}?courseId=c1'),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: PaymentTypesScreen.path,
              builder: (_, state) => PaymentTypesScreen(
                courseId: state.uri.queryParameters['courseId']!,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

DioException _apiError(int status, String message) => DioException(
  requestOptions: RequestOptions(path: 'payments/request'),
  response: Response(
    statusCode: status,
    data: {'message': message},
    requestOptions: RequestOptions(path: 'payments/request'),
  ),
);

void main() {
  testWidgets('opening the screen requests a payment for the course', (
    tester,
  ) async {
    final repo = _Repo();
    await _pump(tester, repo);

    expect(repo.requestedCourses, ['c1']);
    expect(find.byType(PaymentTypeTile), findsNWidgets(2));
    expect(find.text('Payme'), findsOneWidget);
    expect(find.text('Click'), findsOneWidget);
  });

  testWidgets('choosing attaches the type, then opens that provider', (
    tester,
  ) async {
    final repo = _Repo();
    final opened = <Uri>[];
    await _pump(tester, repo, opened: opened);

    await tester.tap(find.text('Click'));
    await tester.pumpAndSettle();

    expect(repo.selections.single.paymentId, 'pa1');
    expect(repo.selections.single.paymentTypeId, 'pt2');
    expect(opened.single, Uri.parse('https://click.uz/pay'));
  });

  testWidgets('prefers the URL the API echoes back', (tester) async {
    final repo = _Repo(echoedUrl: 'https://payme.uz/checkout?order=pa1');
    final opened = <Uri>[];
    await _pump(tester, repo, opened: opened);

    await tester.tap(find.text('Payme'));
    await tester.pumpAndSettle();

    expect(opened.single, Uri.parse('https://payme.uz/checkout?order=pa1'));
  });

  testWidgets('surfaces the API message when attaching fails', (tester) async {
    final repo = _Repo(selectError: _apiError(400, "To'lov turi faol emas"));
    final opened = <Uri>[];
    await _pump(tester, repo, opened: opened);

    await tester.tap(find.text('Payme'));
    await tester.pumpAndSettle();

    expect(opened, isEmpty);
    expect(find.text("To'lov turi faol emas"), findsOneWidget);
  });

  testWidgets('surfaces the API message when the request itself fails', (
    tester,
  ) async {
    await _pump(
      tester,
      _Repo(
        requestError: _apiError(400, 'Siz allaqachon ushbu kursga yozilgansiz'),
      ),
    );

    expect(find.text("Couldn't start the payment"), findsOneWidget);
    expect(
      find.text('Siz allaqachon ushbu kursga yozilgansiz'),
      findsOneWidget,
    );
    expect(find.byType(PaymentTypeTile), findsNothing);
  });

  testWidgets('reports a provider the device cannot open', (tester) async {
    final opened = <Uri>[];
    await _pump(tester, _Repo(), opened: opened, launchSucceeds: false);

    await tester.tap(find.text('Payme'));
    await tester.pumpAndSettle();

    expect(opened, hasLength(1));
    expect(find.text("Couldn't open Payme"), findsOneWidget);
  });

  testWidgets('reports a type with no checkout link', (tester) async {
    final opened = <Uri>[];
    await _pump(
      tester,
      _Repo(
        types: const [PaymentTypeEntity(id: 'pt9', title: 'Uzum')],
      ),
      opened: opened,
    );

    await tester.tap(find.text('Uzum'));
    await tester.pumpAndSettle();

    expect(opened, isEmpty);
    expect(find.text('Uzum has no checkout link yet'), findsOneWidget);
  });

  testWidgets('shows a placeholder when no methods are configured', (
    tester,
  ) async {
    await _pump(tester, _Repo(types: const []));

    expect(find.text('No payment methods'), findsOneWidget);
    expect(find.byType(PaymentTypeTile), findsNothing);
  });

  testWidgets('backing out returns to the caller', (tester) async {
    await _pump(tester, _Repo());

    // Not pageBack() — the screen uses BackIconButton, not a Material one.
    await tester.tap(find.byType(BackIconButton));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(find.byType(PaymentTypeTile), findsNothing);
  });
}
