import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/domain/usecase/use_register.dart';
import 'package:student/core/user/domain/entity/gender.dart';
import 'package:student/core/user/domain/entity/student_level.dart';
import 'package:student/core/user/domain/usecase/use_get_me.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';

final registerControllerProvider =
    AsyncNotifierProvider<RegisterController, void>(RegisterController.new);

/// Drives the session-based registration: the login screen starts it for an
/// identity with no account, `OtpScreen` verifies the code, and
/// `RegisterScreen` completes it with the profile.
///
/// Each step returns whether it succeeded instead of the screens listening
/// for state changes — the login and OTP screens stay mounted underneath the
/// later steps, and a listener there would react to a resend or a later step
/// as if it were its own.
class RegisterController extends AsyncNotifier<void> {
  String? _sessionId;

  @override
  FutureOr<void> build() {}

  /// Sends the code, or resends it for the same identity — the API then
  /// reuses the session (and un-verifies it), at most once every 2 minutes.
  Future<bool> sendOtp({String? phoneNumber, String? email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _sessionId = await ref
          .read(useRegisterProvider)
          .sendOtp(phoneNumber: phoneNumber, email: email);
    });
    return !state.hasError;
  }

  Future<bool> verifyOtp(String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(useRegisterProvider)
          .verifyOtp(sessionId: _requireSession(), code: code),
    );
    return !state.hasError;
  }

  /// [level] comes from the placement quiz and is null when it was skipped.
  /// [gender] is null when the student didn't pick one, leaving the API to
  /// apply its own default.
  Future<bool> complete({
    required String firstName,
    String? lastName,
    required String password,
    StudentLevel? level,
    Gender? gender,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(useRegisterProvider)
          .call(
            sessionId: _requireSession(),
            firstName: firstName,
            lastName: lastName,
            password: password,
            level: level,
            gender: gender,
          );
      // Deleted server-side on success, so it can't be replayed anyway.
      _sessionId = null;
      final user = await ref.read(useGetMeProvider).call();
      ref.read(currentUserProvider.notifier).state = user;
    });
    return !state.hasError;
  }

  String _requireSession() =>
      _sessionId ?? (throw StateError('No registration session started'));
}
