import 'package:student/core/auth/domain/entity/auth_entity.dart';

abstract class IAuthRepository {
  Future<AuthEntity> signIn({
    required String phoneNumber,
    required String password,
  });

  Future<AuthEntity> signUp({
    required String firstName,
    required String phoneNumber,
    required String password,
    required String code,
  });

  Future<void> sendOtp({required String phoneNumber});

  Future<void> recoverPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  });
}
