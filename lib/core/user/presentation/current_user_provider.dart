import 'package:flutter_riverpod/legacy.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';

final currentUserProvider = StateProvider<UserEntity?>((ref) => null);
