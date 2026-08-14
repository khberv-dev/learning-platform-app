import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/domain/usecase/use_send_otp.dart';
import 'package:student/core/auth/domain/usecase/use_sign_up.dart';
import 'package:student/core/user/domain/entity/student_level.dart';
import 'package:student/core/user/domain/usecase/use_get_me.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';

final registerControllerProvider =
    AsyncNotifierProvider<RegisterController, void>(RegisterController.new);

class RegisterController extends AsyncNotifier<void> {
  String? _firstName;
  String? _phoneNumber;
  String? _password;
  StudentLevel? _level;

  @override
  FutureOr<void> build() {}

  /// Step 1: store registration data and send OTP to the phone number.
  ///
  /// [level] comes from the placement quiz and is null when it was skipped.
  Future<void> prepareAndSendOtp({
    required String firstName,
    required String phoneNumber,
    required String password,
    StudentLevel? level,
  }) async {
    _firstName = firstName;
    _phoneNumber = phoneNumber;
    _password = password;
    _level = level;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(useSendOtpProvider).call(phoneNumber: phoneNumber),
    );
  }

  /// Step 2: complete registration using the OTP code entered by the user.
  Future<void> confirmSignUp(String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(useSignUpProvider)
          .call(
            firstName: _firstName!,
            phoneNumber: _phoneNumber!,
            password: _password!,
            code: code,
            level: _level,
          );
      final user = await ref.read(useGetMeProvider).call();
      ref.read(currentUserProvider.notifier).state = user;
    });
  }
}
