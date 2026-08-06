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
    final response = await _dio.get('courses/$courseId/plans');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => PlanResponse.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }
}
