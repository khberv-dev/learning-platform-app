import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/domain/usecase/use_sign_in.dart';
import 'package:student/core/user/domain/usecase/use_get_me.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';

final loginControllerProvider = AsyncNotifierProvider<LoginController, void>(
  LoginController.new,
);

class LoginController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(useSignInProvider)
          .call(phoneNumber: phoneNumber, password: password);
      final user = await ref.read(useGetMeProvider).call();
      ref.read(currentUserProvider.notifier).state = user;
    });
  }
}
