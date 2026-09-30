import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/domain/usecase/use_get_my_groups.dart';

final myGroupsControllerProvider =
    AsyncNotifierProvider<MyGroupsController, List<GroupEntity>>(
      MyGroupsController.new,
    );

class MyGroupsController extends AsyncNotifier<List<GroupEntity>> {
  @override
  FutureOr<List<GroupEntity>> build() =>
      ref.read(useGetMyGroupsProvider).call();
}
