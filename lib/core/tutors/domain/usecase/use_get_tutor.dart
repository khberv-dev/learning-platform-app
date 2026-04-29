import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/tutors/data/repository/tutors_repository.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/core/tutors/domain/repository/i_tutors_repository.dart';

final useGetTutorProvider = Provider<UseGetTutor>(
  (ref) => UseGetTutor(ref.read(tutorsRepositoryProvider)),
);

class UseGetTutor {
  final ITutorsRepository _repository;

  const UseGetTutor(this._repository);

  Future<TutorEntity> call(String id) => _repository.getTutor(id);
}
