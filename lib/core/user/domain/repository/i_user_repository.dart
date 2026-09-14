import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/domain/entity/streak_entity.dart';

abstract class IUserRepository {
  Future<UserEntity> getMe();
  Future<StreakEntity> getStreak();

  /// Marks today (UTC) as active. True only for the first call of the day.
  Future<bool> recordActivity();
}
