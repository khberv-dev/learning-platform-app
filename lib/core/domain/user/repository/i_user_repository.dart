import 'package:student/core/domain/user/entity/user_entity.dart';

abstract class IUserRepository {
  Future<UserEntity> getMe();
}
