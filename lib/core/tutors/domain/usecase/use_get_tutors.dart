import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/tutors/data/repository/tutors_repository.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/core/tutors/domain/repository/i_tutors_repository.dart';

final useGetTutorsProvider = Provider<UseGetTutors>(
  (ref) => UseGetTutors(ref.read(tutorsRepositoryProvider)),
);

class UseGetTutors {
  final ITutorsRepository _repository;

  const UseGetTutors(this._repository);

  Future<List<TutorEntity>> call() => _repository.getTutors();
}
