import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/user/data/repository/user_repository.dart';
import 'package:student/core/user/domain/entity/streak_entity.dart';

final streakProvider = FutureProvider<StreakEntity>(
  (ref) => ref.read(userRepositoryProvider).getStreak(),
);
