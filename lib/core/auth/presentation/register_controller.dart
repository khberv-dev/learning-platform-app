import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/domain/entity/otp_purpose.dart';
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
  String? _email;
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
    _email = null;
    _password = password;
    _level = level;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(useSendOtpProvider)
          .call(phoneNumber: phoneNumber, purpose: OtpPurpose.registration),
    );
  }

  Future<void> prepareEmailAndSendOtp({
    required String firstName,
    required String email,
    required String password,
    StudentLevel? level,
  }) async {
    _firstName = firstName;
    _phoneNumber = null;
    _email = email.trim().toLowerCase();
    _password = password;
    _level = level;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(useSendOtpProvider)
          .callEmail(email: _email!, purpose: OtpPurpose.registration),
    );
  }

  /// Step 2: complete registration using the OTP code entered by the user.
  Future<void> confirmSignUp(String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final signUp = ref.read(useSignUpProvider);
      if (_email != null) {
        await signUp.callEmail(
          firstName: _firstName!,
          email: _email!,
          password: _password!,
          code: code,
          level: _level,
        );
      } else {
        await signUp.call(
          firstName: _firstName!,
          phoneNumber: _phoneNumber!,
          password: _password!,
          code: code,
          level: _level,
        );
      }
      final user = await ref.read(useGetMeProvider).call();
      ref.read(currentUserProvider.notifier).state = user;
    });
  }
}
