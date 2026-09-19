import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/mentors/data/repository/mentors_repository.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/core/mentors/domain/usecase/use_get_mentor.dart';

final mentorDetailControllerProvider =
    FutureProvider.family<MentorEntity, String>(
      (ref, id) => ref.read(useGetMentorProvider).call(id),
    );

final mentorScheduleProvider =
    FutureProvider.family<Map<String, List<String>>, String>(
      (ref, mentorId) =>
          ref.read(mentorsRepositoryProvider).getMentorSchedule(mentorId),
    );
