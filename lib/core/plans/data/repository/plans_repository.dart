import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/plans/data/model/plan_response.dart';
import 'package:student/core/plans/domain/entity/plan_entity.dart';
import 'package:student/core/plans/domain/repository/i_plans_repository.dart';

final plansRepositoryProvider = Provider<IPlansRepository>(
  (ref) => PlansRepository(dio: ref.read(dioClientProvider)),
);

class PlansRepository implements IPlansRepository {
  final Dio _dio;

  const PlansRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<PlanEntity>> getCoursePlans(String courseId) async {
    // Paginated ({ data, total, … }, 10 per page by default). A course has a
    // handful of plans, so one large page holds them all.
    final response = await _dio.get(
      'student/courses/$courseId/plans',
      queryParameters: {'limit': 100},
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List<dynamic>? ?? const [];
    return list
        .map((e) => PlanResponse.fromJson(e as Map<String, dynamic>))
        // A plan taken off sale can't be bought.
        .where((p) => p.isActive)
        .map((p) => p.toEntity())
        .toList();
  }
}
