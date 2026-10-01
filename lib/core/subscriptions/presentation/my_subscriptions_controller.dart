import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/subscriptions/domain/entity/subscription_entity.dart';
import 'package:student/core/subscriptions/domain/usecase/use_get_my_subscriptions.dart';

final mySubscriptionsControllerProvider =
    AsyncNotifierProvider<MySubscriptionsController, List<SubscriptionEntity>>(
      MySubscriptionsController.new,
    );

class MySubscriptionsController
    extends AsyncNotifier<List<SubscriptionEntity>> {
  @override
  FutureOr<List<SubscriptionEntity>> build() =>
      ref.read(useGetMySubscriptionsProvider).call();
}
