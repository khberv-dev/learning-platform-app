import 'package:student/core/groups/domain/entity/group_entity.dart';

abstract class IGroupsRepository {
  /// The student's current group, or null if they aren't in one.
  Future<GroupEntity?> getMyGroup();
}
