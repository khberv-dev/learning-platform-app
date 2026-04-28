import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/user/data/repository/user_repository.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/domain/repository/i_user_repository.dart';

final useGetMeProvider = Provider(
  (ref) => UseGetMe(ref.read(userRepositoryProvider)),
);

class UseGetMe {
  final IUserRepository _repository;

  const UseGetMe(this._repository);

  Future<UserEntity> call() => _repository.getMe();
}
