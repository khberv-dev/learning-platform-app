import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/user/domain/entity/student_level.dart';

abstract class IAuthRepository {
  Future<AuthEntity> signIn({
    required String phoneNumber,
    required String password,
  });

  /// [level] is what the placement quiz scored. Omitted when it wasn't taken,
  /// leaving the API to apply its own default.
  Future<AuthEntity> signUp({
    required String firstName,
    required String phoneNumber,
    required String password,
    required String code,
    StudentLevel? level,
  });

  Future<void> sendOtp({required String phoneNumber});

  Future<void> recoverPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  });
}
