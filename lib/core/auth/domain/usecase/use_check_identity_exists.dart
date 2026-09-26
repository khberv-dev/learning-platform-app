import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/data/repository/auth_repository.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';

final useCheckIdentityExistsProvider = Provider(
  (ref) => UseCheckIdentityExists(ref.read(authRepositoryProvider)),
);

class UseCheckIdentityExists {
  final IAuthRepository _repository;

  const UseCheckIdentityExists(this._repository);

  Future<bool> call(String phoneNumber) =>
      _repository.checkPhoneExists(phoneNumber);

  Future<bool> callEmail(String email) =>
      (_repository as IEmailAuthRepository).checkEmailExists(email);
}
