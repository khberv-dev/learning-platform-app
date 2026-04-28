import 'package:student/core/user/domain/entity/user_entity.dart';

abstract class IUserRepository {
  Future<UserEntity> getMe();
}
