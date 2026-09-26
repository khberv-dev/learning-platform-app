import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/data/repository/auth_repository.dart';
import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';
import 'package:student/core/user/domain/entity/gender.dart';
import 'package:student/core/user/domain/entity/student_level.dart';

final useRegisterProvider = Provider(
  (ref) => UseRegister(ref.read(authRepositoryProvider)),
);

/// The three session-based registration calls, in the order they're made:
/// [sendOtp] → [verifyOtp] → [call].
class UseRegister {
  final IAuthRepository _repository;

  const UseRegister(this._repository);

  Future<String> sendOtp({String? phoneNumber, String? email}) =>
      _repository.sendRegisterOtp(phoneNumber: phoneNumber, email: email);

  Future<void> verifyOtp({required String sessionId, required String code}) =>
      _repository.verifyRegisterOtp(sessionId: sessionId, code: code);

  Future<AuthEntity> call({
    required String sessionId,
    required String firstName,
    String? lastName,
    required String password,
    StudentLevel? level,
    Gender? gender,
  }) => _repository.register(
    sessionId: sessionId,
    firstName: firstName,
    lastName: lastName,
    password: password,
    level: level,
    gender: gender,
  );
}
