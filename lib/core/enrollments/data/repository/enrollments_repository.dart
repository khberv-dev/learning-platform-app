import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/enrollments/data/model/enrollment_history_response.dart';
import 'package:student/core/enrollments/domain/entity/enrollment_history_entity.dart';
import 'package:student/core/enrollments/domain/repository/i_enrollments_repository.dart';

final enrollmentsRepositoryProvider = Provider<IEnrollmentsRepository>(
  (ref) => EnrollmentsRepository(dio: ref.read(dioClientProvider)),
);

class EnrollmentsRepository implements IEnrollmentsRepository {
  final Dio _dio;

  const EnrollmentsRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<EnrollmentHistoryEntity>> getHistory() async {
    final response = await _dio.get('student/enrollments/history');
    final list = response.data as List<dynamic>;
    return list
        .map(
          (e) => EnrollmentHistoryResponse.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList();
  }
}
