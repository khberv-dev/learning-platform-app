import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/subscriptions/data/model/subscription_response.dart';
import 'package:student/core/subscriptions/domain/entity/subscription_entity.dart';
import 'package:student/core/subscriptions/domain/repository/i_subscriptions_repository.dart';

final subscriptionsRepositoryProvider = Provider<ISubscriptionsRepository>(
  (ref) => SubscriptionsRepository(dio: ref.read(dioClientProvider)),
);

class SubscriptionsRepository implements ISubscriptionsRepository {
  final Dio _dio;

  const SubscriptionsRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<SubscriptionEntity>> getMySubscriptions() async {
    // Paginated; one per course, so a single large page holds them all.
    final response = await _dio.get(
      'student/subscriptions',
      queryParameters: {'limit': 100},
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List<dynamic>? ?? const [];
    return list
        .map(
          (e) => SubscriptionResponse.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList();
  }
}
