import 'package:student/core/domain/auth/entity/auth_entity.dart';

abstract class IAuthRepository {
  Future<AuthEntity> signIn({
    required String phoneNumber,
    required String password,
  });
}
