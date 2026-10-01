import 'package:student/core/subscriptions/domain/entity/subscription_entity.dart';

abstract class ISubscriptionsRepository {
  /// Every subscription the student holds, current or expired.
  Future<List<SubscriptionEntity>> getMySubscriptions();
}
