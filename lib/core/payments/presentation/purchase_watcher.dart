import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks a checkout the student was sent off to complete.
///
/// Payment happens on the provider's own site, so the app is never told the
/// outcome directly. Instead it remembers which courses were already owned
/// before the hand-off, and compares once the student comes back.
class PurchaseWatch {
  /// Course ids owned at the moment the student left for checkout.
  final Set<String> knownCourseIds;

  /// The plan being paid for, so a later confirmation can be attributed.
  final String planId;

  const PurchaseWatch({required this.knownCourseIds, required this.planId});
}

final purchaseWatchProvider =
    NotifierProvider<PurchaseWatchController, PurchaseWatch?>(
      PurchaseWatchController.new,
    );

class PurchaseWatchController extends Notifier<PurchaseWatch?> {
  @override
  PurchaseWatch? build() => null;

  void start({required Set<String> knownCourseIds, required String planId}) {
    state = PurchaseWatch(knownCourseIds: knownCourseIds, planId: planId);
  }

  void stop() => state = null;
}
