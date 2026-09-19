import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/mentors/data/model/mentor_response.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/core/mentors/domain/repository/i_mentors_repository.dart';

final mentorsRepositoryProvider = Provider<IMentorsRepository>(
  (ref) => MentorsRepository(dio: ref.read(dioClientProvider)),
);

class MentorsRepository implements IMentorsRepository {
  final Dio _dio;

  const MentorsRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<MentorEntity>> getMentors() async {
    final response = await _dio.get('student/mentors');
    final list = response.data as List<dynamic>;
    return list
        .map(
          (e) => MentorResponse.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<MentorEntity> getMentor(String id) async {
    final response = await _dio.get('student/mentors/$id');
    return MentorResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }

  @override
  Future<Map<String, List<String>>> getMentorSchedule(String mentorId) async {
    final response = await _dio.get('student/mentors/$mentorId/schedule');
    final data = response.data as Map<String, dynamic>? ?? {};
    return data.map(
      (day, slots) => MapEntry(day, List<String>.from(slots as List)),
    );
  }

  @override
  Future<void> leaveFeedback({
    required String id,
    required String text,
    required int rate,
  }) async {
    await _dio.post(
      'student/mentors/$id/feedbacks',
      data: {'text': text, 'rate': rate},
    );
  }
}
