import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/auth/data/repository/auth_repository.dart';
import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/entity/otp_purpose.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';
import 'package:student/core/auth/presentation/otp_controller.dart';
import 'package:student/core/auth/presentation/recover_password_controller.dart';
import 'package:student/core/auth/presentation/register_controller.dart';
import 'package:student/core/user/domain/entity/gender.dart';
import 'package:student/core/user/domain/entity/student_level.dart';

/// Records what the controllers ask the API for, and can be made to fail.
class _FakeAuthRepository implements IAuthRepository {
  final List<({String phoneNumber, OtpPurpose purpose})> otpRequests = [];
  final List<({String phoneNumber, String code, String newPassword})>
  recoveries = [];

  /// Thrown by the next [recoverPassword], standing in for a rejected code.
  Object? recoverError;

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required OtpPurpose purpose,
  }) async {
    otpRequests.add((phoneNumber: phoneNumber, purpose: purpose));
  }

  @override
  Future<void> recoverPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    recoveries.add((
      phoneNumber: phoneNumber,
      code: code,
      newPassword: newPassword,
    ));
    if (recoverError != null) throw recoverError!;
  }

  @override
  Future<bool> checkPhoneExists(String phoneNumber) =>
      throw UnimplementedError();

  @override
  Future<AuthEntity> signIn({
    required String phoneNumber,
    required String password,
  }) => throw UnimplementedError();

  // ── Registration (session-based) ──
  final List<({String? phoneNumber, String? email})> registerOtpRequests = [];
  final List<({String sessionId, String code})> verifications = [];
  final List<({String sessionId, String firstName, StudentLevel? level})>
  registrations = [];

  /// Thrown by the next [verifyRegisterOtp], standing in for a wrong code.
  Object? verifyError;

  @override
  Future<String> sendRegisterOtp({String? phoneNumber, String? email}) async {
    registerOtpRequests.add((phoneNumber: phoneNumber, email: email));
    return 'session-1';
  }

  @override
  Future<void> verifyRegisterOtp({
    required String sessionId,
    required String code,
  }) async {
    verifications.add((sessionId: sessionId, code: code));
    if (verifyError != null) throw verifyError!;
  }

  @override
  Future<AuthEntity> register({
    required String sessionId,
    required String firstName,
    String? lastName,
    required String password,
    StudentLevel? level,
    Gender? gender,
  }) async {
    registrations.add((
      sessionId: sessionId,
      firstName: firstName,
      level: level,
    ));
    return const AuthEntity(accessToken: 'access', refreshToken: 'refresh');
  }
}

({ProviderContainer container, _FakeAuthRepository repo}) _setUp() {
  final repo = _FakeAuthRepository();
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return (container: container, repo: repo);
}

void main() {
  test('recovery asks for a code under the recover purpose', () async {
    final (:container, :repo) = _setUp();

    await container
        .read(recoverPasswordControllerProvider.notifier)
        .prepareAndSendOtp(
          phoneNumber: '998901234567',
          newPassword: 'newSecret123',
        );

    // The default purpose would be refused: the API will not send a
    // registration code to a number that already has an account.
    expect(repo.otpRequests, [
      (phoneNumber: '998901234567', purpose: OtpPurpose.recover),
    ]);
    expect(container.read(recoverPasswordControllerProvider).hasError, isFalse);
  });

  test(
    'registration verifies the code against the session it was sent on',
    () async {
      final (:container, :repo) = _setUp();
      final controller = container.read(registerControllerProvider.notifier);

      expect(await controller.sendOtp(phoneNumber: '998901234567'), isTrue);
      expect(await controller.verifyOtp('123456'), isTrue);

      expect(repo.registerOtpRequests, [
        (phoneNumber: '998901234567', email: null),
      ]);
      // Registration has its own endpoints — nothing under a recover purpose.
      expect(repo.otpRequests, isEmpty);
      expect(repo.verifications, [(sessionId: 'session-1', code: '123456')]);
    },
  );

  test(
    'a wrong registration code reports failure and keeps the session',
    () async {
      final (:container, :repo) = _setUp();
      final controller = container.read(registerControllerProvider.notifier);
      await controller.sendOtp(email: 'sevara@example.com');
      repo.verifyError = Exception('OTP noto\'g\'ri');

      expect(await controller.verifyOtp('000000'), isFalse);
      expect(container.read(registerControllerProvider).hasError, isTrue);

      repo.verifyError = null;
      expect(await controller.verifyOtp('123456'), isTrue);
      expect(repo.verifications.last, (sessionId: 'session-1', code: '123456'));
    },
  );

  test('verifying before a code was sent fails instead of throwing', () async {
    final (:container, :repo) = _setUp();

    final verified = await container
        .read(registerControllerProvider.notifier)
        .verifyOtp('123456');

    expect(verified, isFalse);
    expect(repo.verifications, isEmpty);
  });

  test('a resend keeps the purpose of the flow it belongs to', () async {
    final (:container, :repo) = _setUp();

    await container
        .read(otpControllerProvider.notifier)
        .sendOtp(phoneNumber: '998901234567', purpose: OtpPurpose.recover);

    expect(repo.otpRequests.single.purpose, OtpPurpose.recover);
  });

  test('the code is spent on the password given in step one', () async {
    final (:container, :repo) = _setUp();
    final controller = container.read(
      recoverPasswordControllerProvider.notifier,
    );

    await controller.prepareAndSendOtp(
      phoneNumber: '998901234567',
      newPassword: 'newSecret123',
    );
    await controller.confirmRecovery('123456');

    expect(repo.recoveries, [
      (
        phoneNumber: '998901234567',
        code: '123456',
        newPassword: 'newSecret123',
      ),
    ]);
    expect(container.read(recoverPasswordControllerProvider).hasError, isFalse);
  });

  test('a rejected code surfaces as an error, not a silent success', () async {
    final (:container, :repo) = _setUp();
    final controller = container.read(
      recoverPasswordControllerProvider.notifier,
    );
    repo.recoverError = Exception('OTP is wrong or expired');

    await controller.prepareAndSendOtp(
      phoneNumber: '998901234567',
      newPassword: 'newSecret123',
    );
    await controller.confirmRecovery('000000');

    expect(container.read(recoverPasswordControllerProvider).hasError, isTrue);
  });

  test('a rejected code leaves the flow able to try the next one', () async {
    final (:container, :repo) = _setUp();
    final controller = container.read(
      recoverPasswordControllerProvider.notifier,
    );
    repo.recoverError = Exception('OTP is wrong or expired');

    await controller.prepareAndSendOtp(
      phoneNumber: '998901234567',
      newPassword: 'newSecret123',
    );
    await controller.confirmRecovery('000000');

    // The password from step one is still there for a second attempt.
    repo.recoverError = null;
    await controller.confirmRecovery('123456');

    expect(repo.recoveries.last.newPassword, 'newSecret123');
    expect(container.read(recoverPasswordControllerProvider).hasError, isFalse);
  });

  test('the new password is dropped once it has been accepted', () async {
    final (:container, :repo) = _setUp();
    final controller = container.read(
      recoverPasswordControllerProvider.notifier,
    );

    await controller.prepareAndSendOtp(
      phoneNumber: '998901234567',
      newPassword: 'newSecret123',
    );
    await controller.confirmRecovery('123456');

    // This provider outlives the screens, so a stale second attempt must not
    // replay the password it was holding.
    await controller.confirmRecovery('123456');

    expect(repo.recoveries, hasLength(1));
    expect(container.read(recoverPasswordControllerProvider).hasError, isTrue);
  });
}
