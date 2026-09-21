import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/domain/usecase/use_get_my_group.dart';

final myGroupControllerProvider =
    AsyncNotifierProvider<MyGroupController, GroupEntity?>(
      MyGroupController.new,
    );

class MyGroupController extends AsyncNotifier<GroupEntity?> {
  @override
  FutureOr<GroupEntity?> build() => ref.read(useGetMyGroupProvider).call();
}
