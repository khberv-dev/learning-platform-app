import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/live_lessons/domain/entity/live_lesson_scheduled_entity.dart';
import 'package:student/core/live_lessons/domain/usecase/use_get_my_live_lessons.dart';

final myLiveLessonsProvider =
    AsyncNotifierProvider<
      MyLiveLessonsController,
      List<LiveLessonScheduledEntity>
    >(MyLiveLessonsController.new);

class MyLiveLessonsController
    extends AsyncNotifier<List<LiveLessonScheduledEntity>> {
  @override
  FutureOr<List<LiveLessonScheduledEntity>> build() =>
      ref.read(useGetMyLiveLessonsProvider).call();
}
