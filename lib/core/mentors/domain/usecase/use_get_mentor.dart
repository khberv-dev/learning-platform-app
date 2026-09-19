import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/mentors/data/repository/mentors_repository.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/core/mentors/domain/repository/i_mentors_repository.dart';

final useGetMentorProvider = Provider<UseGetMentor>(
  (ref) => UseGetMentor(ref.read(mentorsRepositoryProvider)),
);

class UseGetMentor {
  final IMentorsRepository _repository;

  const UseGetMentor(this._repository);

  Future<MentorEntity> call(String id) => _repository.getMentor(id);
}
