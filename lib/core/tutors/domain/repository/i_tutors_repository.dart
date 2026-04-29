import 'package:student/core/tutors/domain/entity/tutor_entity.dart';

abstract class ITutorsRepository {
  Future<List<TutorEntity>> getTutors();
}
