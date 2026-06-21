import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/assignments/data/model/assignment_response.dart';
import 'package:student/core/assignments/domain/entity/assignment_entity.dart';
import 'package:student/core/assignments/domain/repository/i_assignments_repository.dart';

final assignmentsRepositoryProvider = Provider<IAssignmentsRepository>(
  (ref) => AssignmentsRepository(dio: ref.read(dioClientProvider)),
);

class AssignmentsRepository implements IAssignmentsRepository {
  final Dio _dio;

  const AssignmentsRepository({required Dio dio}) : _dio = dio;

  @override
  Future<AssignmentEntity> createAssignment({
    required String teacherId,
    required DateTime startDate,
  }) async {
    final response = await _dio.post(
      'assignments',
      data: {
        'teacherId': teacherId,
        'startDate': startDate.toUtc().toIso8601String(),
      },
    );

    return AssignmentResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }
}
