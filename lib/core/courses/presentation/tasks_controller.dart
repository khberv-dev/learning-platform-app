import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/domain/entity/task_entity.dart';
import 'package:student/core/courses/domain/entity/task_result_entity.dart';
import 'package:student/core/courses/domain/usecase/use_get_lesson_results.dart';
import 'package:student/core/courses/domain/usecase/use_get_tasks.dart';

typedef TasksParams = ({String courseId, String unitId, String lessonId});

final tasksControllerProvider =
    FutureProvider.family<List<TaskEntity>, TasksParams>(
      (ref, params) => ref
          .read(useGetTasksProvider)
          .call(
            courseId: params.courseId,
            unitId: params.unitId,
            lessonId: params.lessonId,
          ),
    );

final lessonTaskResultsProvider =
    FutureProvider.family<List<TaskResultEntity>, String>(
      (ref, lessonId) => ref.read(useGetLessonResultsProvider).call(lessonId),
    );
