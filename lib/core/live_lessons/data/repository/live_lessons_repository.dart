import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/live_lessons/data/model/live_lesson_scheduled_response.dart';
import 'package:student/core/live_lessons/domain/entity/live_lesson_scheduled_entity.dart';
import 'package:student/core/live_lessons/domain/repository/i_live_lessons_repository.dart';

final liveLessonsRepositoryProvider = Provider<ILiveLessonsRepository>(
  (ref) => LiveLessonsRepository(dio: ref.read(dioClientProvider)),
);

class LiveLessonsRepository implements ILiveLessonsRepository {
  final Dio _dio;

  const LiveLessonsRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<LiveLessonScheduledEntity>> getMyLessons() async {
    final response = await _dio.get(
      'live-lessons/my',
      queryParameters: {'limit': 100},
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List<dynamic>;
    return list
        .map(
          (e) => LiveLessonScheduledResponse.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList();
  }
}
