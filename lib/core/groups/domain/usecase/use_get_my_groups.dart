import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/groups/data/repository/groups_repository.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/domain/repository/i_groups_repository.dart';

final useGetMyGroupsProvider = Provider<UseGetMyGroups>(
  (ref) => UseGetMyGroups(ref.read(groupsRepositoryProvider)),
);

class UseGetMyGroups {
  final IGroupsRepository _repository;

  const UseGetMyGroups(this._repository);

  Future<List<GroupEntity>> call() => _repository.getMyGroups();
}
