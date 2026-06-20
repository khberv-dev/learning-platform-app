import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/data/repository/auth_repository.dart';
import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';

final useSignUpProvider = Provider(
  (ref) => UseSignUp(ref.read(authRepositoryProvider)),
);

class UseSignUp {
  final IAuthRepository _repository;

  const UseSignUp(this._repository);

  Future<AuthEntity> call({
    required String firstName,
    required String phoneNumber,
    required String password,
    required String code,
  }) => _repository.signUp(
    firstName: firstName,
    phoneNumber: phoneNumber,
    password: password,
    code: code,
  );
}
