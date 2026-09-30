import 'package:student/core/groups/domain/entity/group_entity.dart';

abstract class IGroupsRepository {
  /// Every group the student is in — one per course. Empty if none.
  Future<List<GroupEntity>> getMyGroups();
}
