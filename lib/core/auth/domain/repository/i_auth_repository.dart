import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/entity/otp_purpose.dart';
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

  /// [purpose] decides which checks the API applies, so it has to match the
  /// flow asking for the code.
  Future<void> sendOtp({
    required String phoneNumber,
    required OtpPurpose purpose,
  });

  /// Consumes the [code] sent for [OtpPurpose.recover] and sets the new
  /// password. The code is one-shot: a failure here means asking for another.
  Future<void> recoverPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  });
}

/// Email capabilities added alongside the original phone authentication
/// contract. Kept separate so existing phone-only repository substitutes stay
/// valid while the production repository supports both identities.
abstract class IEmailAuthRepository {
  Future<AuthEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthEntity> signUpWithEmail({
    required String firstName,
    required String email,
    required String password,
    required String code,
    StudentLevel? level,
  });

  Future<void> sendEmailOtp({
    required String email,
    required OtpPurpose purpose,
  });
}
