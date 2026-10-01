import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/subscriptions/data/repository/subscriptions_repository.dart';
import 'package:student/core/subscriptions/domain/entity/subscription_entity.dart';
import 'package:student/core/subscriptions/domain/repository/i_subscriptions_repository.dart';

final useGetMySubscriptionsProvider = Provider<UseGetMySubscriptions>(
  (ref) => UseGetMySubscriptions(ref.read(subscriptionsRepositoryProvider)),
);

class UseGetMySubscriptions {
  final ISubscriptionsRepository _repository;

  const UseGetMySubscriptions(this._repository);

  Future<List<SubscriptionEntity>> call() => _repository.getMySubscriptions();
}
