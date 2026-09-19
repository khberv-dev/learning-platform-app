import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/mentors/data/repository/mentors_repository.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/core/mentors/domain/repository/i_mentors_repository.dart';

final useGetMentorsProvider = Provider<UseGetMentors>(
  (ref) => UseGetMentors(ref.read(mentorsRepositoryProvider)),
);

class UseGetMentors {
  final IMentorsRepository _repository;

  const UseGetMentors(this._repository);

  Future<List<MentorEntity>> call() => _repository.getMentors();
}
