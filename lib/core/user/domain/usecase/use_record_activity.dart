import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/user/data/repository/user_repository.dart';
import 'package:student/core/user/domain/repository/i_user_repository.dart';

final useRecordActivityProvider = Provider(
  (ref) => UseRecordActivity(ref.read(userRepositoryProvider)),
);

class UseRecordActivity {
  final IUserRepository _repository;

  const UseRecordActivity(this._repository);

  Future<bool> call() => _repository.recordActivity();
}
