import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/assessments/data/model/assessment_turn_response.dart';
import 'package:student/core/assessments/data/model/conversation_response.dart';
import 'package:student/core/assessments/domain/entity/assessment_turn_entity.dart';
import 'package:student/core/assessments/domain/entity/conversation_entity.dart';
import 'package:student/core/assessments/domain/repository/i_assessment_repository.dart';

final assessmentRepositoryProvider = Provider<IAssessmentRepository>(
  (ref) => AssessmentRepository(dio: ref.read(dioClientProvider)),
);

class AssessmentRepository implements IAssessmentRepository {
  final Dio _dio;

  const AssessmentRepository({required Dio dio}) : _dio = dio;

  @override
  Future<ConversationEntity> createConversation() async {
    final response = await _dio.post('assessments/conversations');
    return ConversationResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }

  @override
  Future<AssessmentTurnEntity> sendTurn({
    required String conversationId,
    required String audioFilePath,
  }) async {
    final form = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioFilePath,
        filename: 'turn.m4a',
        contentType: DioMediaType('audio', 'mp4'),
      ),
    });

    final response = await _dio.post(
      'assessments/conversations/$conversationId/messages',
      data: form,
    );

    return AssessmentTurnResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }
}
