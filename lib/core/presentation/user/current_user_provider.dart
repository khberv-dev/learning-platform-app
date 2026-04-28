import 'package:flutter_riverpod/legacy.dart';
import 'package:student/core/domain/user/entity/user_entity.dart';

final currentUserProvider = StateProvider<UserEntity?>((ref) => null);
