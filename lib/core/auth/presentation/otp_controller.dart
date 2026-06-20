import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/domain/usecase/use_send_otp.dart';

final otpControllerProvider = AsyncNotifierProvider<OtpController, void>(
  OtpController.new,
);

class OtpController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> sendOtp({required String phoneNumber}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(useSendOtpProvider).call(phoneNumber: phoneNumber),
    );
  }
}
