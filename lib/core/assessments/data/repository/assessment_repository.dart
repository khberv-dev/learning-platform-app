import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/assessments/domain/entity/assessment_feedback_entity.dart';
import 'package:student/core/assessments/domain/repository/i_assessment_repository.dart';

final assessmentRepositoryProvider = Provider<IAssessmentRepository>(
  (ref) => AssessmentRepository(dio: ref.read(dioClientProvider)),
);

class AssessmentRepository implements IAssessmentRepository {
  final Dio _dio;

  const AssessmentRepository({required Dio dio}) : _dio = dio;

  @override
  Future<AssessmentFeedbackEntity> submit({
    required String audioFilePath,
  }) async {
    final form = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioFilePath,
        filename: 'answer.m4a',
      ),
    });

    final response = await _dio.post('assessments', data: form);
    final data = response.data;

    String? text;
    String? audio;
    if (data is Map) {
      if (data['feedbackText'] is String) text = data['feedbackText'] as String;
      if (data['feedbackAudio'] is String) {
        audio = data['feedbackAudio'] as String;
      }
    }
    return AssessmentFeedbackEntity(feedbackText: text, feedbackAudio: audio);
  }
}
