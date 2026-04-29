import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/domain/usecase/use_sign_up.dart';
import 'package:student/core/user/domain/usecase/use_get_me.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';

final registerControllerProvider =
    AsyncNotifierProvider<RegisterController, void>(RegisterController.new);

class RegisterController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signUp({
    required String firstName,
    required String phoneNumber,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(useSignUpProvider)
          .call(
            firstName: firstName,
            phoneNumber: phoneNumber,
            password: password,
          );
      final user = await ref.read(useGetMeProvider).call();
      ref.read(currentUserProvider.notifier).state = user;
    });
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
