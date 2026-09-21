import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/groups/data/repository/groups_repository.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/domain/repository/i_groups_repository.dart';

final useGetMyGroupProvider = Provider<UseGetMyGroup>(
  (ref) => UseGetMyGroup(ref.read(groupsRepositoryProvider)),
);

class UseGetMyGroup {
  final IGroupsRepository _repository;

  const UseGetMyGroup(this._repository);

  Future<GroupEntity?> call() => _repository.getMyGroup();
}
