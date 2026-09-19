import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/core/mentors/domain/usecase/use_get_mentors.dart';

final mentorsControllerProvider =
    AsyncNotifierProvider<MentorsController, List<MentorEntity>>(
      MentorsController.new,
    );

class MentorsController extends AsyncNotifier<List<MentorEntity>> {
  @override
  FutureOr<List<MentorEntity>> build() =>
      ref.read(useGetMentorsProvider).call();
}
