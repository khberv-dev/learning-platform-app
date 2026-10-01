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
  Future<List<AssignmentEntity>> getMyAssignments() async {
    // Paginated; one per subscription, so a single large page holds them all.
    final response = await _dio.get(
      'student/assignments',
      queryParameters: {'limit': 100},
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List<dynamic>? ?? const [];
    return list
        .map(
          (e) =>
              AssignmentResponse.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<AssignmentEntity> requestAssignment({
    required String subscriptionId,
    required List<ScheduleSlot> schedule,
  }) async {
    final response = await _dio.post(
      'student/assignments',
      data: {
        'subscriptionId': subscriptionId,
        'schedule': [
          for (final slot in schedule) {slot.day.name: slot.time},
        ],
      },
    );
    return AssignmentResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }
}
