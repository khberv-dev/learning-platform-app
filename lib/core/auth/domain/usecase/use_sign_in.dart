import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/data/repository/auth_repository.dart';
import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';

final useSignInProvider = Provider(
  (ref) => UseSignIn(ref.read(authRepositoryProvider)),
);

class UseSignIn {
  final IAuthRepository _repository;

  const UseSignIn(this._repository);

  Future<AuthEntity> call({
    required String phoneNumber,
    required String password,
  }) => _repository.signIn(phoneNumber: phoneNumber, password: password);
}
