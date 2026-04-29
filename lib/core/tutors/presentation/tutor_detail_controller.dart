import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/core/tutors/domain/usecase/use_get_tutor.dart';

final tutorDetailControllerProvider =
    FutureProvider.family<TutorEntity, String>(
      (ref, id) => ref.read(useGetTutorProvider).call(id),
    );
