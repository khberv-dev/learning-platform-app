import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/core/mentors/domain/usecase/use_get_mentor.dart';

final mentorDetailControllerProvider =
    FutureProvider.family<MentorEntity, String>(
      (ref, id) => ref.read(useGetMentorProvider).call(id),
    );
