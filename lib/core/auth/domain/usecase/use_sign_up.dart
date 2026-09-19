import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/data/repository/auth_repository.dart';
import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';
import 'package:student/core/user/domain/entity/student_level.dart';

final useSignUpProvider = Provider(
  (ref) => UseSignUp(ref.read(authRepositoryProvider)),
);

class UseSignUp {
  final IAuthRepository _repository;

  const UseSignUp(this._repository);

  Future<AuthEntity> call({
    required String firstName,
    String? lastName,
    required String phoneNumber,
    required String password,
    required String code,
    StudentLevel? level,
  }) => _repository.signUp(
    firstName: firstName,
    lastName: lastName,
    phoneNumber: phoneNumber,
    password: password,
    code: code,
    level: level,
  );

  Future<AuthEntity> callEmail({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
    required String code,
    StudentLevel? level,
  }) => (_repository as IEmailAuthRepository).signUpWithEmail(
    firstName: firstName,
    lastName: lastName,
    email: email,
    password: password,
    code: code,
    level: level,
  );
}
