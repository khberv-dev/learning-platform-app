import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/data/repository/auth_repository.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';

final useRecoverPasswordProvider = Provider(
  (ref) => UseRecoverPassword(ref.read(authRepositoryProvider)),
);

class UseRecoverPassword {
  final IAuthRepository _repository;

  const UseRecoverPassword(this._repository);

  Future<void> call({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) => _repository.recoverPassword(
    phoneNumber: phoneNumber,
    code: code,
    newPassword: newPassword,
  );
}
