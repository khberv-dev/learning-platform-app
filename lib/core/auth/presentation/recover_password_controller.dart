import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/domain/entity/otp_purpose.dart';
import 'package:student/core/auth/domain/usecase/use_recover_password.dart';
import 'package:student/core/auth/domain/usecase/use_send_otp.dart';

final recoverPasswordControllerProvider =
    AsyncNotifierProvider<RecoverPasswordController, void>(
      RecoverPasswordController.new,
    );

class RecoverPasswordController extends AsyncNotifier<void> {
  String? _phoneNumber;
  String? _newPassword;

  @override
  FutureOr<void> build() {}

  /// Step 1: hold on to the new password and ask for a code.
  ///
  /// [OtpPurpose.recover] is what makes this work at all — under the default
  /// purpose the API refuses to send a code to a number that already has an
  /// account, which is every number that can recover a password.
  Future<void> prepareAndSendOtp({
    required String phoneNumber,
    required String newPassword,
  }) async {
    _phoneNumber = phoneNumber;
    _newPassword = newPassword;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(useSendOtpProvider)
          .call(phoneNumber: phoneNumber, purpose: OtpPurpose.recover),
    );
  }

  /// Step 2: spend the code on the password held since step 1.
  ///
  /// The code is one-shot on the API side, so a failure here — a wrong or
  /// expired code — means asking for a new one rather than retrying this.
  Future<void> confirmRecovery(String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(useRecoverPasswordProvider)
          .call(
            phoneNumber: _phoneNumber!,
            code: code,
            newPassword: _newPassword!,
          ),
    );

    // Only once it has been accepted: a failed attempt still has the same
    // password to offer the next code. This provider outlives the screens, so
    // the plaintext should not sit in it for the rest of the session.
    if (!state.hasError) {
      _phoneNumber = null;
      _newPassword = null;
    }
  }
}
