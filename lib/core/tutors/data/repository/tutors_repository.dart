import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/tutors/data/model/tutor_response.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/core/tutors/domain/repository/i_tutors_repository.dart';

final tutorsRepositoryProvider = Provider<ITutorsRepository>(
  (ref) => TutorsRepository(dio: ref.read(dioClientProvider)),
);

class TutorsRepository implements ITutorsRepository {
  final Dio _dio;

  const TutorsRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<TutorEntity>> getTutors() async {
    final response = await _dio.get('teachers');
    final list = response.data as List<dynamic>;
    return list
        .map(
          (e) => TutorResponse.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<TutorEntity> getTutor(String id) async {
    final response = await _dio.get('teachers/$id');
    return TutorResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }

  @override
  Future<Map<String, List<String>>> getTeacherSchedule(String teacherId) async {
    final response = await _dio.get('teachers/$teacherId/schedule');
    final data = response.data as Map<String, dynamic>? ?? {};
    return data.map(
      (day, slots) => MapEntry(day, List<String>.from(slots as List)),
    );
  }
}
