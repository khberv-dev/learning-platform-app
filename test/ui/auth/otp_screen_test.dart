import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/core/auth/data/repository/auth_repository.dart';
import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/entity/otp_purpose.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';
import 'package:student/core/auth/presentation/recover_password_controller.dart';
import 'package:student/core/auth/presentation/register_controller.dart';
import 'package:student/core/user/domain/entity/gender.dart';
import 'package:student/core/user/domain/entity/student_level.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/auth/otp_screen.dart';
import 'package:student/ui/auth/register_screen.dart';

import '../../support/localized_app.dart';

const _phone = '998901234567';

class _FakeAuthRepository implements IAuthRepository {
  final List<OtpPurpose> otpPurposes = [];

  /// Thrown by the next [sendOtp] — the API refuses a resend inside its own
  /// cooldown, and more than five in an hour.
  Object? sendError;

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required OtpPurpose purpose,
  }) async {
    otpPurposes.add(purpose);
    if (sendError != null) throw sendError!;
  }

  @override
  Future<void> recoverPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {}

  @override
  Future<bool> checkPhoneExists(String phoneNumber) =>
      throw UnimplementedError();

  @override
  Future<AuthEntity> signIn({
    required String phoneNumber,
    required String password,
  }) => throw UnimplementedError();

  // ── Registration (session-based) ──
  final List<String?> registerOtpPhones = [];
  final List<String> verifiedCodes = [];

  /// Thrown by the next [sendRegisterOtp] — the 2-minute resend cooldown.
  Object? registerSendError;

  @override
  Future<String> sendRegisterOtp({String? phoneNumber, String? email}) async {
    registerOtpPhones.add(phoneNumber);
    if (registerSendError != null) throw registerSendError!;
    return 'session-1';
  }

  @override
  Future<void> verifyRegisterOtp({
    required String sessionId,
    required String code,
  }) async {
    verifiedCodes.add(code);
  }

  @override
  Future<AuthEntity> register({
    required String sessionId,
    required String firstName,
    String? lastName,
    required String password,
    StudentLevel? level,
    Gender? gender,
  }) => throw UnimplementedError();
}

/// A 429 shaped the way the API sends one, message and all.
DioException _tooManyRequests(String message) => DioException(
  requestOptions: RequestOptions(path: 'auth/otp/send'),
  response: Response(
    requestOptions: RequestOptions(path: 'auth/otp/send'),
    statusCode: 429,
    data: {'message': message, 'statusCode': 429},
  ),
);

Future<({ProviderContainer container, _FakeAuthRepository repo})> _pumpOtp(
  WidgetTester tester, {
  OtpMode mode = OtpMode.recoverPassword,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final repo = _FakeAuthRepository();
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: localizedApp(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => OtpScreen(phoneNumber: _phone, mode: mode),
            ),
            GoRoute(
              path: RegisterScreen.path,
              builder: (_, _) =>
                  const Scaffold(body: Center(child: Text('register'))),
            ),
            GoRoute(
              path: LoginScreen.path,
              builder: (_, _) =>
                  const Scaffold(body: Center(child: Text('login'))),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  return (container: container, repo: repo);
}

/// Resend stays disabled through a 2-minute countdown.
Future<void> _waitForResend(WidgetTester tester, {int seconds = 120}) async {
  await tester.pump(Duration(seconds: seconds + 1));
}

AppFlatPillButton _button(WidgetTester tester, String label) => tester
    .widget<AppFlatPillButton>(find.widgetWithText(AppFlatPillButton, label));

/// Taps Resend and lets the request settle.
///
/// Pumped by hand rather than with `pumpAndSettle`: resending restarts the
/// countdown, and a ticking timer never settles.
Future<void> _tapResend(WidgetTester tester) async {
  await tester.tap(find.text('Resend code'));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('the code goes to the number it was sent to', (tester) async {
    await _pumpOtp(tester);

    expect(find.textContaining('+998 90 123 45 67'), findsOneWidget);
    expect(find.text('02:00'), findsOneWidget);
  });

  testWidgets('Continue waits for all six digits, then submits them', (
    tester,
  ) async {
    final (:container, :repo) = await _pumpOtp(tester, mode: OtpMode.register);
    await container
        .read(registerControllerProvider.notifier)
        .sendOtp(phoneNumber: _phone);

    await tester.enterText(find.byType(EditableText), '12345');
    await tester.pump();
    expect(_button(tester, 'Continue').onTap, isNull);
    expect(repo.verifiedCodes, isEmpty);

    await tester.enterText(find.byType(EditableText), '123456');
    await tester.pumpAndSettle();
    expect(repo.verifiedCodes, ['123456']);
  });

  testWidgets('resending in recovery asks under the recover purpose', (
    tester,
  ) async {
    final (:container, :repo) = await _pumpOtp(tester);

    await _waitForResend(tester);
    await _tapResend(tester);

    expect(repo.otpPurposes, [OtpPurpose.recover]);
  });

  testWidgets('registration resends on its own session after 2 minutes', (
    tester,
  ) async {
    final (:container, :repo) = await _pumpOtp(tester, mode: OtpMode.register);
    await container
        .read(registerControllerProvider.notifier)
        .sendOtp(phoneNumber: _phone);
    repo.registerOtpPhones.clear();

    await _waitForResend(tester, seconds: 60);
    expect(
      _button(tester, 'Resend code').onTap,
      isNull,
      reason: 'still cooling down',
    );
    expect(find.text('00:59'), findsOneWidget);

    await _waitForResend(tester, seconds: 60);
    await _tapResend(tester);

    expect(repo.registerOtpPhones, [_phone]);
    expect(repo.otpPurposes, isEmpty);
  });

  testWidgets('a refused registration resend says so', (tester) async {
    final (:container, :repo) = await _pumpOtp(tester, mode: OtpMode.register);
    repo.registerSendError = _tooManyRequests(
      "Yangi kod so'rash uchun 43 soniya kuting",
    );

    await _waitForResend(tester, seconds: 120);
    await _tapResend(tester);

    expect(
      find.text("Yangi kod so'rash uchun 43 soniya kuting"),
      findsOneWidget,
    );
  });

  testWidgets('a verified registration code moves on to the profile form', (
    tester,
  ) async {
    final (:container, :repo) = await _pumpOtp(tester, mode: OtpMode.register);
    await container
        .read(registerControllerProvider.notifier)
        .sendOtp(phoneNumber: _phone);

    await tester.enterText(find.byType(EditableText), '123456');
    await tester.pumpAndSettle();

    expect(repo.verifiedCodes, ['123456']);
    expect(find.text('register'), findsOneWidget);
  });

  testWidgets('a refused resend says so instead of starting a silent wait', (
    tester,
  ) async {
    final (:container, :repo) = await _pumpOtp(tester);
    repo.sendError = _tooManyRequests(
      "Yangi kod so'rash uchun 43 soniya kuting",
    );

    await _waitForResend(tester);
    await _tapResend(tester);

    // The API's own wording, which is as specific as we can be about the wait.
    expect(
      find.text("Yangi kod so'rash uchun 43 soniya kuting"),
      findsOneWidget,
    );
  });

  testWidgets('a finished recovery reports it and returns to login', (
    tester,
  ) async {
    final (:container, :repo) = await _pumpOtp(tester);

    await container
        .read(recoverPasswordControllerProvider.notifier)
        .prepareAndSendOtp(phoneNumber: _phone, newPassword: 'newSecret123');
    await tester.pump();
    await container
        .read(recoverPasswordControllerProvider.notifier)
        .confirmRecovery('123456');
    await tester.pumpAndSettle();

    expect(find.text('Password updated successfully'), findsOneWidget);
    expect(find.text('login'), findsOneWidget);
  });
}
