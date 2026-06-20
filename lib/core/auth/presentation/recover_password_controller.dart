import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// Step 1: store recovery data and send OTP to the phone number.
  Future<void> prepareAndSendOtp({
    required String phoneNumber,
    required String newPassword,
  }) async {
    _phoneNumber = phoneNumber;
    _newPassword = newPassword;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(useSendOtpProvider).call(phoneNumber: phoneNumber),
    );
  }

  /// Step 2: verify OTP and update the password.
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
  }

  static String errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final msg = data['message'];
        if (msg is String) return msg;
        if (msg is List && msg.isNotEmpty) return msg.first.toString();
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
