import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/user/data/repository/user_repository.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/domain/repository/i_user_repository.dart';

final useUploadAvatarProvider = Provider(
  (ref) => UseUploadAvatar(ref.read(userRepositoryProvider)),
);

class UseUploadAvatar {
  final IUserRepository _repository;

  const UseUploadAvatar(this._repository);

  Future<UserEntity> call(String imagePath) =>
      _repository.uploadAvatar(imagePath);
}
