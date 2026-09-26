import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/entity/otp_purpose.dart';
import 'package:student/core/user/domain/entity/gender.dart';
import 'package:student/core/user/domain/entity/student_level.dart';

abstract class IAuthRepository {
  /// Whether a student account already exists for [phoneNumber] — checked
  /// before the login screen decides whether to ask for a password.
  Future<bool> checkPhoneExists(String phoneNumber);

  Future<AuthEntity> signIn({
    required String phoneNumber,
    required String password,
  });

  /// Starts (or, for the same identity, resends on) a registration session
  /// and returns its id. Exactly one of [phoneNumber] / [email] is given. The
  /// API refuses an identity that already has a student account.
  Future<String> sendRegisterOtp({String? phoneNumber, String? email});

  /// Marks the session verified. A wrong code counts against the session's
  /// five attempts.
  Future<void> verifyRegisterOtp({
    required String sessionId,
    required String code,
  });

  /// Creates the account for the identity verified on [sessionId].
  ///
  /// [level] is what the placement quiz scored. Omitted when it wasn't taken,
  /// leaving the API to apply its own default. [lastName] and [gender] are
  /// optional too — the API defaults an omitted [gender] to male.
  Future<AuthEntity> register({
    required String sessionId,
    required String firstName,
    String? lastName,
    required String password,
    StudentLevel? level,
    Gender? gender,
  });

  /// Sends a password-recovery code ([OtpPurpose.recover]). Registration has
  /// its own session-based endpoints above.
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
  /// Whether a student account already exists for [email].
  Future<bool> checkEmailExists(String email);

  Future<AuthEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> sendEmailOtp({
    required String email,
    required OtpPurpose purpose,
  });
}
