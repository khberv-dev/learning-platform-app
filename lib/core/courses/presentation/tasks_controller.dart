import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/domain/entity/task_entity.dart';
import 'package:student/core/courses/domain/usecase/use_get_tasks.dart';

typedef TasksParams = ({String courseId, String unitId, String lessonId});

// autoDispose: TasksScreen is pushed and popped, so this is torn down with it
// and a revisit always re-fetches instead of replaying stale answers/state.
final tasksControllerProvider = FutureProvider.autoDispose
    .family<List<TaskEntity>, TasksParams>(
      (ref, params) => ref
          .read(useGetTasksProvider)
          .call(
            courseId: params.courseId,
            unitId: params.unitId,
            lessonId: params.lessonId,
          ),
    );
