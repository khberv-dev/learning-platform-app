import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/domain/entity/streak_entity.dart';

abstract class IUserRepository {
  Future<UserEntity> getMe();
  Future<StreakEntity> getStreak();
}
