import 'package:student/core/auth/domain/entity/auth_entity.dart';

abstract class IAuthRepository {
  Future<AuthEntity> signIn({
    required String phoneNumber,
    required String password,
  });
}
