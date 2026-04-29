import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/core/tutors/domain/usecase/use_get_tutors.dart';

final tutorsControllerProvider =
    AsyncNotifierProvider<TutorsController, List<TutorEntity>>(
  TutorsController.new,
);

class TutorsController extends AsyncNotifier<List<TutorEntity>> {
  @override
  FutureOr<List<TutorEntity>> build() =>
      ref.read(useGetTutorsProvider).call();
}
